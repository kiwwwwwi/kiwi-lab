# API 그룹

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

## 코어 리소스에 그룹이 없는 이유

역사적 이유다. 쿠버네티스 초기에는 Pod, Service 같은 핵심 리소스를 그룹 개념 없이 `/api/v1`에 바로 등록했다. 이후 리소스가 늘어나면서 `apps`, `batch`, `networking.k8s.io` 같은 그룹 체계가 생겼는데, 기존 코어 리소스는 하위 호환성 때문에 그대로 유지됐다.

```
초기 설계   → /api/v1 (그룹 없음)
그룹 도입   → /apis/{그룹}/v1
코어 리소스 → 이미 /api/v1에 있으니 그대로 둠 (바꾸면 기존 yaml 다 깨짐)
```