# kubelet

각 노드에서 실행되는 에이전트. API Server를 Watch하다가 자기 노드에 배정된 Pod 스펙이 오면 containerd에 컨테이너 실행을 요청한다.

이름은 `kube` + `-let`(작은 ~) 조합. 클러스터 전체를 관리하는 컨트롤 플레인과 달리 노드 하나에서 컨테이너 실행만 담당하는 작은 에이전트라는 의미.

```
API Server에 Pod 스펙 저장
  → kubelet이 감지 (자기 노드에 배정된 Pod)
  → containerd에 컨테이너 실행 요청
  → 실제 프로세스 기동
```

## 역할

- 컨테이너 실행/중지 요청 (containerd에 위임)
- 컨테이너 상태 모니터링 → API Server에 보고
- 죽은 컨테이너 재시작

## 노드 구성

kube-proxy, containerd와 함께 모든 노드에 하나씩 떠 있다.

```
노드
  ├── kubelet    → 컨테이너 실행 관리
  ├── kube-proxy → iptables 관리
  └── containerd → 실제 컨테이너 런타임
```