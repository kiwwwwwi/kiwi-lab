# Controller

"선언된 상태"와 "실제 상태"를 맞추는 루프.

## 감지 방식 (Watch)

주기적으로 API Server를 확인하는 폴링이 아니라 Watch 방식이다. API Server에 "이 리소스 변경되면 알려줘"라고 등록해두고 이벤트를 받는다.

```
Controller 시작
  → API Server에 Watch 등록 ("kind: Kafka 변경되면 알려줘")
  → 대기

사용자가 kubectl apply -f kafka.yaml
  → etcd에 저장
  → API Server가 Controller에게 이벤트 전송
  → Controller가 Reconcile 실행
```

```
선언: replicas: 3 (파드 3개여야 함)
실제: 파드 2개 떠 있음
  → Controller 감지 → 파드 1개 추가 생성
```

이 루프를 **Reconcile Loop**라고 한다. 실제 상태를 계속 확인하고 선언과 다르면 맞춰준다.

## 쿠버네티스 기본 Controller

| Controller | 역할 |
|---|---|
| ReplicaSet Controller | 파드 수 유지 |
| Deployment Controller | 롤링 업데이트 관리 |
| Endpoint Controller | Service에 파드 IP 등록/제거 |

## 오퍼레이터의 Controller

오퍼레이터도 같은 구조다. 커스텀 리소스를 Watch하다가 선언과 실제 상태가 다르면 맞춰준다.

```
사용자 선언: kind: Kafka (Kafka 클러스터 있어야 함)
실제 상태:   아무것도 없음
  → Strimzi Controller → StatefulSet/Service/ConfigMap 생성
```

Controller가 Kafka 프로세스를 직접 띄우는 게 아니라 쿠버네티스 오브젝트를 만들고, 이후 kubelet → containerd 흐름이 실제 컨테이너를 실행한다.

## Controller vs kubelet

Controller는 "무엇이 있어야 한다"를 결정하고, kubelet은 "어떻게 실행한다"를 담당한다.

```
Controller → Pod 오브젝트 생성 (API Server → etcd)
Scheduler  → Pod를 어느 노드에서 실행할지 결정
kubelet    → 내 노드에 배정된 Pod 감지 → containerd에 실행 요청
```

Controller는 Pod 오브젝트(선언)를 만드는 것까지만 한다. containerd와 어떻게 통신하는지, 실제 컨테이너를 어떻게 실행하는지는 노드에 붙어있는 kubelet의 역할이다.
