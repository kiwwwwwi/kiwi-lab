# Node

클러스터를 구성하는 서버(머신) 하나하나.

```
클러스터
  ├── 컨트롤 플레인 노드
  │     ├── API Server
  │     ├── etcd
  │     ├── Scheduler
  │     └── Controller Manager
  │
  └── 워커 노드 (여러 개)
        ├── kubelet        ← API Server와 통신, 파드 관리
        ├── kube-proxy     ← iptables 관리
        ├── containerd     ← 컨테이너 실행
        └── 파드들
```

## 컨트롤 플레인 노드

클러스터 두뇌. API Server 등 관리 컴포넌트가 실행된다.

## 워커 노드

실제 앱이 돌아가는 곳. kubelet이 API Server를 Watch하다가 파드 실행 명령을 받으면 containerd에 요청한다.

```
API Server → kubelet → containerd → 컨테이너 실행
```

물리 서버일 수도 있고 VM일 수도 있다. 로컬에서 docker-desktop이나 minikube를 쓰면 노드가 1개짜리 클러스터다.