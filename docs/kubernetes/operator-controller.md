# Operator & Controller

## Controller

특정 리소스의 현재 상태를 원하는 상태로 맞추는 루프.

```
원하는 상태 (spec)   → replicas: 3
현재 상태 (status)   → 파드 2개 실행 중
Controller 동작      → 파드 1개 추가
```

쿠버네티스 내부에 기본으로 포함되어 있다. (Deployment Controller, ReplicaSet Controller 등)

## Operator

Controller + CRD + 도메인 지식의 묶음.

Controller 패턴을 활용해서 쿠버네티스가 기본으로 관리하지 못하는 복잡한 애플리케이션을 자동으로 관리하는 확장 도구다.

```
쿠버네티스 기본 Controller
  파드 죽으면 재시작  ← 이 정도는 기본 제공

Kafka 같은 복잡한 앱
  브로커 추가 시 파티션 재분배
  버전 업그레이드 시 롤링 재시작
  ← 쿠버네티스가 모르는 도메인 지식 → Operator가 처리
```

## 관계

Operator가 더 큰 개념이고, Controller는 Operator 안에 포함된 구성 요소다.

```
Strimzi Operator
  ├── CRD 등록      (kind: Kafka, KafkaNodePool 등)
  ├── Controller    (Kafka 리소스 감시 → 상태 조정)
  └── 도메인 지식  (파티션 재분배, 롤링 업그레이드 등)
```

Strimzi를 설치하면 `kind: Kafka` 같은 CRD를 등록하고, 그 리소스를 감시하다가 변경이 생기면 Kafka 클러스터를 알아서 조정한다.
