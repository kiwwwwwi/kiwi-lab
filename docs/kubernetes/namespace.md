# Namespace

리소스를 논리적으로 격리하는 공간.

리소스가 많아졌을 때 한 공간에 뒤섞이는 걸 방지하기 위해 사용한다.

```
kiwi-lab   → mysql, kafka, schema-registry
argocd     → argocd 관련 리소스
monitoring → grafana, prometheus
```

## 효과

**이름 충돌 방지**
같은 이름의 리소스가 네임스페이스별로 독립적으로 존재할 수 있다.
```
kiwi-lab/mysql 과 monitoring/mysql 은 별개로 존재 가능
```

**권한 분리**
팀 A는 kiwi-lab만, 팀 B는 monitoring만 접근하도록 제한할 수 있다.

**리소스 쿼터**
네임스페이스별로 CPU, 메모리 사용량 상한을 설정할 수 있다.

## 네임스페이스 간 통신

같은 네임스페이스 안에서는 Service 이름만으로 통신할 수 있다.
다른 네임스페이스 리소스는 풀네임으로 접근해야 한다.

```
같은 네임스페이스   → kafka:9092
다른 네임스페이스   → kafka.kiwi-lab.svc.cluster.local:9092
```

## apiVersion과의 관계

관련 없는 개념이다.

```yaml
apiVersion: kafka.strimzi.io/v1  # API 버전 스펙 → 리소스 종류 분류
kind: Kafka
metadata:
  namespace: kiwi-lab             # 네임스페이스 → 배포 공간 분리
```

`apiVersion`의 API 그룹(`kafka.strimzi.io`)은 리소스 종류를 분류하는 논리적 묶음이고, 네임스페이스는 실제 배포 공간을 분리하는 것으로 별개다.
