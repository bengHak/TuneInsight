# SpotifyStats

Tuist로 구성된 멀티 모듈 iOS 프로젝트입니다.

## 프로젝트 구조

```
SpotifyStats/
├── Workspace.swift
├── Tuist.swift
├── Projects/
│   ├── Application/         # 메인 앱 모듈
│   └── Modules/
│       ├── DIKit/          # 의존성 주입
│       ├── DataKit/        # 데이터 레이어
│       ├── DomainKit/      # 도메인 레이어
│       ├── FoundationKit/  # 공통 유틸리티
│       ├── PresentationKit/ # UI 레이어
│       └── ThirdPartyManager/ # 써드파티 라이브러리 관리
├── Tuist/
│   ├── Package.swift      # SPM 의존성
│   └── ProjectDescriptionHelpers/ # Tuist 헬퍼
├── BuildConfigurations/   # 빌드 설정
└── Scripts/              # 스크립트 파일들
```

## 시작하기

### 1. 프로젝트 생성

```bash
tuist generate
```

### 2. 프로젝트 빌드

```bash
tuist build
```

### 3. 테스트 실행

```bash
tuist test
```

## 모듈 설명

- **Application**: 메인 앱 타겟으로 모든 모듈을 통합합니다.
- **DIKit**: Swinject를 기반으로 한 의존성 주입 관리
- **DataKit**: Repository 패턴과 데이터 소스 관리
- **DomainKit**: 비즈니스 로직과 엔티티 정의
- **FoundationKit**: 공통 유틸리티와 익스텐션
- **PresentationKit**: UI 컴포넌트와 뷰 모델
- **ThirdPartyManager**: 외부 라이브러리 래핑 및 관리

## 개발 환경

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Tuist 4.0+

## 라이브러리

- **ComposableArchitecture**: 상태 관리
- **Alamofire**: 네트워킹
- **Swinject**: 의존성 주입

## 기여하기

1. 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`)
2. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`)
3. 브랜치에 푸시합니다 (`git push origin feature/amazing-feature`)
4. Pull Request를 생성합니다

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.
