# apiVersion

리소스가 어떤 API 그룹의 어떤 버전 스펙을 따르는지 선언하는 필드.

API Server가 `apiVersion + kind` 조합으로 어떤 리소스인지 판단한다.

```yaml
apiVersion: kafka.strimzi.io/v1
kind: Kafka
# kafka.strimzi.io → API 그룹
# v1               → 버전
```

## API 그룹

관련된 리소스들을 묶어서 관리하는 논리적 분류.

같은 `kind` 이름이 여러 오퍼레이터에서 충돌할 수 있기 때문에 그룹명으로 구분한다.

```
kafka.strimzi.io/v1   → Strimzi의 Kafka
other-operator.io/v1  → 다른 오퍼레이터의 Kafka
```

쿠버네티스 기본 리소스는 그룹 없이 버전만 쓴다.

```yaml
apiVersion: v1        # Pod, Service, ConfigMap 등
apiVersion: apps/v1   # Deployment, StatefulSet 등
```

## 버전 성숙도

```
v1beta1, v1beta2  → 베타. 스펙이 바뀔 수 있음
v1                → 안정. 하위 호환성 보장
```

Strimzi처럼 CRD로 등록된 커스텀 리소스는 베타로 출시했다가 스펙이 안정되면 v1으로 승격된다. v1이 더 최신이고 안정적이다.
