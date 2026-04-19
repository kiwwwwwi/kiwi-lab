# CRD (Custom Resource Definition)

쿠버네티스에 없는 리소스 타입을 직접 정의하는 것.

## 개념

쿠버네티스 기본 리소스는 `Pod`, `Deployment`, `Service` 등이다. `Kafka`는 기본 리소스가 아니기 때문에 그냥 `kubectl apply -f kafka.yaml`을 하면 에러가 난다.

Strimzi 오퍼레이터를 설치하면 `kind: Kafka`라는 새로운 리소스 타입을 CRD로 클러스터에 등록한다.

```
CRD 등록 전 → kubectl apply -f kafka.yaml
              error: no kind "Kafka" is registered

CRD 등록 후 → API Server가 kind: Kafka 인식
              Strimzi Controller가 Watch하다가 처리
```

API Server의 어휘집에 새 단어를 추가하는 것.

## 오퍼레이터와의 관계

오퍼레이터 설치 = CRD 등록 + 그걸 처리하는 Controller 배포.

```
Strimzi 설치
  ├── CRD 등록        → kind: Kafka, KafkaNodePool 등을 API Server가 인식
  └── Controller 배포 → 해당 리소스를 Watch하다가 상태 조정
```

## 리소스 생성 전체 흐름

```
1. Operator 설치
   → CRD 등록 (API Server가 kind: Kafka를 알게 됨)
   → Controller 배포 (Watch 대기)

2. 사용자가 kubectl apply -f kafka.yaml
   → API Server가 CRD 스펙으로 검증 후 etcd에 저장

3. Controller가 감지
   → StatefulSet, Service, ConfigMap 등 쿠버네티스 오브젝트 생성

4. kubelet이 감지 → containerd에 컨테이너 실행 요청
   → 실제 Kafka 프로세스 기동
```

Controller는 "Kafka 클러스터를 구성하는 쿠버네티스 리소스들"을 만드는 역할이고, 실제 컨테이너 실행은 그 이후 일반 쿠버네티스 흐름(kubelet → containerd)이 담당한다.