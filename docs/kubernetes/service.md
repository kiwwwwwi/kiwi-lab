# Service

파드에 접근하는 고정된 진입점.

파드는 죽었다 살아나면 IP가 바뀌는데, Service는 항상 같은 이름과 IP를 유지하면서 클라이언트가 파드 교체를 신경 쓰지 않아도 되게 한다.

논리적 흐름 (개념):
```
클라이언트 → Service(kafbat:80) → Pod(kafbat-ui)
```

실제 패킷 흐름:
```
클라이언트 → ClusterIP:80 → [iptables NAT] → 파드 IP:포트
```
Service 오브젝트는 패킷 경로 위에 없다. iptables가 커널 레벨에서 목적지를 바꿔치기한다.

## Service 오브젝트의 역할

Service 오브젝트는 패킷 흐름에 직접 관여하지 않는다. 역할은 **선언**이다.

```
Service 생성
  → kube-proxy가 감지 → iptables에 규칙 등록 (ClusterIP → 파드 IP)
  → CoreDNS가 감지   → DNS에 이름 등록 (kafka → ClusterIP)
```

이후 실제 패킷이 흐를 때는 커널의 iptables와 CoreDNS가 처리한다. Service는 그 둘에게 설정을 지시하는 역할만 한다.

## 등록 위치

Service가 생성되면 두 곳에 등록된다.

- **CoreDNS** — 이름으로 조회할 수 있도록 DNS 등록
- **iptables** — ClusterIP로 오는 패킷을 실제 파드 IP로 전달하는 규칙 등록

```
DNS     : kafbat.kiwi-lab.svc.cluster.local → 10.96.x.x
iptables: 10.96.x.x:80 → 172.17.0.5:8080 (파드 IP)
```

## 파드 교체 시 흐름

파드가 죽고 새로 뜰 때 DNS 이름과 ClusterIP는 변하지 않고, kube-proxy가 iptables 규칙만 업데이트한다.

```
1. 파드 죽음 → Endpoint에서 해당 파드 IP 제거
2. kube-proxy 감지 → iptables에서 죽은 파드 IP 규칙 제거
3. 새 파드 뜸 → Endpoint에 새 파드 IP 추가
4. kube-proxy 감지 → iptables에 새 파드 IP 규칙 등록
```

kube-proxy 상세는 [kube-proxy.md](kube-proxy.md) 참고.

클라이언트는 항상 같은 주소(kafbat:80)로 요청하면 되고, 파드 교체를 신경 쓸 필요가 없다.

## DNS 이름 축약

같은 네임스페이스 안에서는 짧게 사용할 수 있다.

```
kafbat.kiwi-lab.svc.cluster.local  # 풀네임
kafbat.kiwi-lab                    # 네임스페이스까지
kafbat                             # 같은 네임스페이스면 이것만으로 OK
```

`bootstrapServers: kafka:9092` 처럼 짧게 쓸 수 있는 이유도 같은 원리다.

## 타입

| 타입 | 접근 범위 |
|------|-----------|
| ClusterIP | 클러스터 내부에서만 (기본값) |
| NodePort | 노드 IP:포트로 외부 접근 |
| LoadBalancer | 클라우드 LB를 프로비저닝해서 외부 접근 |

docker-desktop(macOS)에서는 NodePort를 열어도 VM IP(`172.18.0.4`)에만 열려서 localhost에서 접근이 안 된다.
결국 ClusterIP든 NodePort든 port-forward로 우회해야 한다.

## Q&A

**Q. ClusterIP와 파드 IP를 분리한 이유는 고정 IP, 유동 IP 때문인가?**

맞다. 클라이언트가 파드 IP로 직접 통신하면 파드가 죽을 때마다 IP를 다시 알아내야 하는 문제가 생긴다. 고정된 ClusterIP를 중간에 두고 파드 IP는 iptables가 내부적으로 관리하는 구조다.

```
ClusterIP  → 고정. Service가 살아있는 한 절대 안 바뀜
파드 IP    → 유동. 파드가 재시작되면 새 IP 할당
```

**Q. ClusterIP는 쿠버네티스에서 할당하는 고정 IP 주소 대역인가?**

맞다. 클러스터 설치 시 설정된 대역(기본값 `10.96.0.0/12`) 안에서 Service마다 하나씩 자동 할당된다. 실제 네트워크 인터페이스에 붙은 IP가 아니라 iptables 규칙으로만 존재하는 가상 IP다. 패킷이 이 IP로 오면 커널이 가로채서 파드로 보낸다.

**Q. ClusterIP의 "클러스터"는 무슨 의미인가?**

클러스터 내부에서만 유효한 IP라는 의미다. 클러스터 외부(맥북 브라우저 등)에서는 이 IP를 알 수 없고 접근도 불가능하다.

```
클러스터 외부 (맥북 브라우저)  → 10.96.x.x 모름, 접근 불가
클러스터 내부 (다른 파드)      → 10.96.x.x 알고 있음, 접근 가능
```

**Q. "ClusterIP로 오는 패킷"이라는 말은 외부에서 보내는 건가?**

아니다. 클러스터 내부 파드끼리 통신할 때의 얘기다. 외부는 ClusterIP를 모르니까 이 흐름에 진입 자체를 못한다.

```
kafbat 파드가 kafka:9092 로 요청
  → DNS 조회 → 10.96.112.33 반환
  → kafbat 파드가 10.96.112.33:9092 로 패킷 전송
  → 커널이 iptables 규칙 확인 → 172.17.0.8:9092 (kafka 파드 IP) 로 바꿔치기
  → kafka 파드에 전달
```

**Q. iptables 규칙 확인이라는 건 ClusterIP와 매핑된 파드 IP를 찾는다는 건가?**

맞다. iptables에 아래와 같은 규칙이 등록되어 있고, 커널이 목적지 IP를 실제 파드 IP로 바꿔치기한 뒤 전달한다.

```
iptables 규칙:
  10.96.112.33:9092 → 172.17.0.8:9092 (kafka 파드 IP)
```
