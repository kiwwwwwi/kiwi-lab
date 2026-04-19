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

## API Server URL 매핑

`apiVersion`은 API Server의 엔드포인트 경로와 1:1로 매핑된다.

```
apiVersion: apps/v1  →  /apis/apps/v1/namespaces/.../deployments
apiVersion: v1       →  /api/v1/namespaces/.../pods
```

그룹이 있으면 `/apis/그룹/버전/...`, 코어 리소스(`v1`)는 그룹 없이 `/api/버전/...` 경로를 사용한다.

`kubectl apply` 시 kubectl이 이 경로로 API Server에 HTTPS 요청을 보내고, API Server가 `apiVersion + kind`를 보고 스펙을 검증한 뒤 etcd에 저장한다.

실제 요청 URL은 `kubectl get pods -v 9`로 확인할 수 있다.

## 버전 성숙도

```
v1beta1, v1beta2  → 베타. 스펙이 바뀔 수 있음
v1                → 안정. 하위 호환성 보장
```

Strimzi처럼 CRD로 등록된 커스텀 리소스는 베타로 출시했다가 스펙이 안정되면 v1으로 승격된다. v1이 더 최신이고 안정적이다.
