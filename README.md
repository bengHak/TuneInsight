# SpotifyStats

멀티 모듈 아키텍처와 Tuist로 구성된 Spotify 통계 앱 프로젝트입니다. 청취 이력과 인기 트랙/아티스트, 플레이리스트 관리 등 Spotify 데이터를 통합적으로 조회하고 제어할 수 있도록 구성되어 있습니다.

## 개발 환경 및 주요 스택
- iOS 17.0+, Xcode 15.0+, Swift 5.9+
- Tuist 4.x 기반 워크스페이스 구성
- Alamofire 네트워킹, Swinject 기반 DI(`DIKit`), ReactorKit/Coordinator를 활용한 Presentation 계층

## 빌드 & 테스트 가이드
- 워크스페이스 생성: `tuist generate --no-open`
- 빌드: `tuist build` 또는 `./Scripts/build.sh`
- 테스트: `tuist test` 또는 `./Scripts/test.sh`
- 빌드 설정: `BuildConfigurations/Debug.xcconfig`, `BuildConfigurations/Release.xcconfig`

## 프로젝트 구조
```
SpotifyStats/
├── Workspace.swift
├── Tuist.swift
├── Tuist/
│   ├── Package.swift
│   └── ProjectDescriptionHelpers/
├── BuildConfigurations/
│   ├── Debug.xcconfig
│   └── Release.xcconfig
├── Projects/
│   ├── Application/
│   │   ├── Sources/
│   │   ├── Resources/
│   │   ├── Tests/
│   │   └── Project.swift
│   └── Modules/
│       ├── DataKit/
│       ├── DomainKit/
│       ├── FoundationKit/
│       ├── PresentationKit/
│       ├── DIKit/
│       └── ThirdPartyManager/
├── Scripts/
│   ├── build.sh
│   └── test.sh
└── README.md
```

## 모듈 구성 및 역할
- **Application**: 앱 진입점. `AppCoordinator`를 통해 플로우를 구성하고 각 모듈을 주입합니다.
- **PresentationKit**: ReactorKit/Coordinator 구조를 활용한 화면·UI 컴포넌트. 앱 공통 UI와 리액터 로직을 관리합니다.
- **DomainKit**: 도메인 엔티티와 유스케이스(`GetTopTracksUseCase`, `GetUserPlaylistsUseCase`, `PlaybackControlUseCase` 등)를 정의하여 비즈니스 규칙을 캡슐화합니다.
- **DataKit**: `SpotifyService`, `SpotifyRepositoryImpl`을 중심으로 API 호출, 응답 매핑(`SpotifyMapper`)과 인증/인터셉터 처리를 담당합니다.
- **DIKit**: Swinject 기반 의존성 그래프. 각 모듈의 `*Assembly`를 통해 서비스 및 유스케이스를 주입합니다.
- **FoundationKit**: 공통 유틸리티, 확장, 기본 타입을 제공합니다.
- **ThirdPartyManager**: 외부 라이브러리 래핑과 버전 관리를 위한 헬퍼를 포함합니다.

## 기능 스펙 개요 (Domain 기준)
- 상위 트랙/아티스트 조회: `GetTopTracksUseCase`, `GetTopArtistsUseCase`
- 최근 재생 기록 조회: `GetRecentlyPlayedUseCase`
- 플레이리스트 CRUD: 생성/수정/삭제(`CreatePlaylistUseCase`, `UpdatePlaylistUseCase`, `DeletePlaylistUseCase`), 트랙 추가/삭제(`AddTracksToPlaylistUseCase`, `RemoveTracksFromPlaylistUseCase`), 상세 조회(`GetPlaylistDetailUseCase`)
- 앨범 및 트랙 탐색: `GetAlbumTracksUseCase`, `SearchTracksUseCase`
- 재생 제어: `PlaybackControlUseCase`, `GetCurrentPlaybackUseCase`

## 개발 워크플로
- 계층 간 의존성: Presentation → Domain → Data 순방향 의존만 허용
- DI 구성: Application에서 각 모듈의 Assembly를 묶어 Swinject 컨테이너 구성
- 네트워킹: `DataKit`의 `SpotifyService` + `Alamofire`를 통한 REST 호출, Mapper로 Domain 엔티티 변환
- 상태 관리: Presentation 계층에서 ReactorKit와 Coordinator 패턴으로 화면 플로우 제어

## 테스트
- 테스트 위치: 각 모듈의 `Projects/*/Tests`
- 신규 기능이나 버그 수정 시 회귀 테스트를 `tuist test`로 실행
- 데이터/도메인 유스케이스에 대한 단위 테스트를 우선 작성하고, 필요 시 UI 모듈에 스냅샷/리액터 테스트 추가 권장

## 스크립트
- `./Scripts/build.sh`: 환경 변수 세팅 후 `tuist build` 실행
- `./Scripts/test.sh`: 동일한 설정으로 `tuist test` 실행

## 기여 가이드
1. 브랜치 생성: `feature/<scope>-<desc>` 또는 `fix/<scope>-<desc>`
2. 커밋 메시지: `[Module] 명령형 요약` 형태 권장 (예: `[DataKit] Update playlist mapper`)
3. PR에는 변경 요약, 동기, 테스트 방법을 기재하고 UI 변경 시 스크린샷 포함

## 라이선스
이 프로젝트는 MIT License를 따릅니다.
