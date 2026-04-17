# Ingress

외부 HTTP 요청을 클러스터 내부 Service로 라우팅하는 규칙을 정의하는 리소스.

ClusterIP는 클러스터 내부에서만 통하고, port-forward는 터미널이 켜있는 동안만 동작하는 임시 터널이라 항상 켜둬야 하는 불편함이 있다. Ingress는 이 문제를 해결한다.

```
외부 브라우저
  → ingress.kafbat.com
  → Ingress (규칙 확인)
  → kafbat Service (ClusterIP)
  → kafbat 파드
```

## port-forward와의 차이

| | port-forward | Ingress |
|---|---|---|
| 동작 조건 | 터미널 켜있는 동안만 | 항상 |
| 접근 방식 | localhost:포트 | 도메인 |
| 용도 | 로컬 개발 | 운영 환경 |

## 로컬에서 비활성화하는 이유

로컬에서는 port-forward로 충분하기 때문에 `ingress.enabled: false`로 둔다.
운영 환경에서 도메인으로 서비스를 노출할 때 활성화한다.

## Ingress Controller

Ingress 리소스는 규칙만 정의하고, 실제로 트래픽을 처리하는 건 **Ingress Controller** 파드다.

```
외부 요청
  → Ingress Controller (nginx, traefik 등) ← 실제 트래픽 처리
  → Ingress 규칙 참조
  → ClusterIP → 파드
```

Ingress Controller는 기본으로 설치되지 않아서 별도로 설치해야 한다. (nginx-ingress, traefik 등)

## IngressClass

클러스터에 Ingress Controller가 여러 개 있을 때 **어떤 Controller가 이 Ingress를 처리할지** 지정하는 것.

```yaml
ingressClassName: nginx   # nginx Ingress Controller가 처리
ingressClassName: traefik # traefik Ingress Controller가 처리
```

Controller가 하나뿐이면 생략해도 되지만, 여러 개면 명시해야 한다. Controller가 하나일 때 기본값으로 설정해두면 생략 가능하다.

실제로 `ingressClassName`은 `IngressClass` 리소스를 가리키고, 그 리소스가 어떤 Controller와 연결되는지 정의한다.

```
Ingress → IngressClass → Ingress Controller → Service → 파드
```

## Q&A

**Q. NodePort면 Ingress가 필요 없는 거 아닌가?**

NodePort만으로도 외부 접근은 가능하지만 한계가 있다. 서비스마다 포트를 하나씩 열어야 하고, TLS나 도메인 기반 라우팅을 직접 처리해야 한다.

```
NodePort 방식               Ingress 방식
  kafbat  → 도메인.com:32000     kafbat  → kafbat.도메인.com
  grafana → 도메인.com:32001     grafana → grafana.도메인.com
  argocd  → 도메인.com:32002     argocd  → argocd.도메인.com
```

**Q. 서브도메인을 다르게 두면 NodePort로도 구분할 수 있지 않나?**

안 된다. NodePort는 L4(IP:포트) 레벨에서 동작해서 도메인을 볼 수 없다. 서브도메인 구분은 HTTP 헤더(`Host: kafbat.도메인.com`)를 읽어야 가능한데, NodePort는 패킷을 통과시키기만 하고 그 레벨까지 처리하지 않는다.

```
L4 (NodePort) → IP:포트 만 본다
L7 (Ingress)  → IP:포트 + Host 헤더 + Path 까지 본다
```

NodePort는 OSI 4계층(TCP/UDP 포트 레벨), Ingress는 7계층(HTTP 애플리케이션 레벨)이라 다룰 수 있는 정보 자체가 다르다.
