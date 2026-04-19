# kube-proxy

각 노드에 떠 있는 데몬. Service 오브젝트를 Watch하다가 변화가 생기면 해당 노드의 iptables 규칙을 업데이트한다.

Service는 "선언"만 하고, kube-proxy는 그 선언을 실제 커널 규칙으로 만드는 실행자다.

```
Service 생성/변경/삭제
  → kube-proxy가 감지
  → 해당 노드의 iptables에 ClusterIP → 파드 IP 규칙 추가/수정/삭제
```

## 역할

Service와 Endpoints 오브젝트를 둘 다 Watch한다. 둘 다 있어야 iptables 규칙을 완성할 수 있다.

```
Service   → 10.96.112.33:9092 라는 규칙이 필요하다  (ClusterIP:포트)
Endpoints → 목적지는 172.17.0.8:9092 이다          (파드 IP:포트)
kube-proxy → iptables에 10.96.112.33:9092 → 172.17.0.8:9092 등록
```

## Endpoint 오브젝트

kube-proxy가 Watch하는 대상은 Service 외에 **Endpoint**도 있다.

Endpoint는 Service에 연결된 실제 파드 IP 목록을 관리하는 오브젝트다. 파드가 뜨고 죽을 때마다 자동으로 업데이트된다.

```
Service 생성 → Endpoint 오브젝트 자동 생성
파드 뜸      → Endpoint에 파드 IP 추가
파드 죽음    → Endpoint에서 파드 IP 제거
```

kube-proxy는 Endpoint 변화를 감지해서 iptables를 갱신한다.

## 파드 교체 시 흐름

```
1. 파드 죽음
   → Endpoint에서 해당 파드 IP 제거
   → kube-proxy 감지 → iptables에서 죽은 파드 IP 규칙 제거

2. 새 파드 뜸
   → Endpoint에 새 파드 IP 추가
   → kube-proxy 감지 → iptables에 새 파드 IP 규칙 등록
```

클라이언트는 ClusterIP로 계속 요청하고, 커널이 iptables 규칙으로 실제 파드 IP를 찾아 전달한다.

## 로드 밸런싱

파드 레플리카가 여러 개일 때 iptables 규칙에 확률 가중치를 넣어 트래픽을 분산한다.

```
파드 3개짜리 Service
  → iptables: 33% 확률로 파드A, 33% 파드B, 33% 파드C
```

## NodePort 처리

NodePort Service는 ClusterIP도 함께 할당된다. NodePort는 ClusterIP 위에 쌓인 레이어다.

```
NodePort Service 생성
  → ClusterIP: 10.96.x.x  (내부용)
  → NodePort:  30080       (외부용)
  둘 다 같은 파드로 연결
```

kube-proxy는 Service마다 파드 선택 로직을 담은 iptables 체인을 하나 만든다.

```
KUBE-SVC-KAFKA (파드 선택 체인)
  → 50% 확률로 파드A IP로 DNAT
  → 50% 확률로 파드B IP로 DNAT
```

ClusterIP 트래픽과 NodePort 트래픽 모두 이 체인을 공통으로 거친다.

```
ClusterIP:9092 로 온 패킷  → KUBE-SVC-KAFKA 체인 → 파드 IP
NodePort:30092 로 온 패킷  → KUBE-SVC-KAFKA 체인 → 파드 IP
```

패킷이 ClusterIP 주소를 목적지로 이동하는 게 아니라, 같은 규칙 묶음을 공유하는 구조다.

## 배포 형태

모든 노드에 DaemonSet으로 배포된다. 각 노드가 자신의 iptables를 직접 관리한다.