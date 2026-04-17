# API Server

쿠버네티스의 모든 요청이 통과하는 중앙 진입점.

모든 구성 요소는 서로 직접 통신하지 않고 API Server를 통해서만 통신한다.

## 역할

- 클러스터 상태 변경 요청을 받아 etcd에 저장
- 각 구성 요소(kubelet, kube-proxy, CoreDNS 등)에 변경 사항 전파
- 인증/인가 처리

## 통신 흐름

```
kubectl apply -f service.yaml
  → API Server (HTTPS)
  → etcd에 저장
  → kube-proxy 감지 → iptables 업데이트
  → CoreDNS 감지 → DNS 등록
  → kubelet 감지 → 컨테이너 실행
```

## kubectl과의 관계

`kubectl`은 API Server에 REST 요청을 보내는 HTTP 클라이언트다.

```
kubectl get pods
= GET https://kubernetes.default.svc/api/v1/namespaces/.../pods
```

`~/.kube/config`에 API Server 주소와 인증 정보가 저장되어 있어 어느 클러스터에 요청할지 결정한다.

## 컨트롤 플레인 내 위치

```
컨트롤 플레인
  ├── API Server          ← 모든 요청의 진입점
  ├── etcd                ← 클러스터 상태 저장 DB
  ├── Scheduler           ← 파드를 어느 노드에 띄울지 결정
  └── Controller Manager  ← 파드 수 유지, 재시작 등 상태 관리
```
