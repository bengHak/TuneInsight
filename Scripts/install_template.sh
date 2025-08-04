#!/bin/bash

# Tuist Template 설치 스크립트
# 현재 프로젝트를 Tuist Templates 디렉터리에 복사합니다.

set -e

# 스크립트 시작 메시지
echo "🚀 Tuist Template 설치를 시작합니다..."

# Tuist 설치 경로를 찾는 함수
find_tuist_path() {
    local tuist_path=""
    
    # 1. which 명령어로 tuist 경로 찾기
    if command -v tuist &> /dev/null; then
        tuist_path=$(which tuist)
        echo "✅ tuist를 찾았습니다: $tuist_path" >&2
        
        # tuist가 실제로 실행 가능한지 확인
        if [ ! -x "$tuist_path" ]; then
            echo "❌ tuist 파일에 실행 권한이 없습니다: $tuist_path" >&2
            return 1
        fi
    else
        echo "❌ 시스템 PATH에서 tuist를 찾을 수 없습니다." >&2
        return 1
    fi
    
    # tuist 실행 파일의 디렉터리 경로 추출
    local tuist_bin_dir=$(dirname "$tuist_path")
    echo "📂 Tuist bin 디렉터리: $tuist_bin_dir" >&2
    
    # bin 디렉터리가 존재하는지 확인
    if [ ! -d "$tuist_bin_dir" ]; then
        echo "❌ Tuist bin 디렉터리가 존재하지 않습니다: $tuist_bin_dir" >&2
        return 1
    fi
    
    # Templates 디렉터리 경로 생성
    local templates_dir="$tuist_bin_dir/Templates"
    
    # Templates 디렉터리가 없으면 생성
    if [ ! -d "$templates_dir" ]; then
        echo "📁 Templates 디렉터리를 생성합니다: $templates_dir" >&2
        if ! mkdir -p "$templates_dir" 2>/dev/null; then
            echo "❌ Templates 디렉터리 생성에 실패했습니다: $templates_dir" >&2
            echo "   권한을 확인하거나 sudo를 사용해보세요." >&2
            return 1
        fi
    fi
    
    # Templates 디렉터리에 쓰기 권한이 있는지 확인
    if [ ! -w "$templates_dir" ]; then
        echo "❌ Templates 디렉터리에 쓰기 권한이 없습니다: $templates_dir" >&2
        echo "   권한을 확인하거나 sudo를 사용해보세요." >&2
        return 1
    fi
    
    echo "$templates_dir"
}

# 현재 프로젝트 경로
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 현재 디렉터리가 유효한지 확인
if [ ! -d "$CURRENT_DIR" ]; then
    echo "❌ 현재 프로젝트 디렉터리를 찾을 수 없습니다: $CURRENT_DIR"
    exit 1
fi

PROJECT_NAME="$(basename "$CURRENT_DIR")"

# 프로젝트 이름이 유효한지 확인
if [ -z "$PROJECT_NAME" ]; then
    echo "❌ 프로젝트 이름을 확인할 수 없습니다."
    exit 1
fi

echo "📍 현재 프로젝트 경로: $CURRENT_DIR"
echo "📝 프로젝트 이름: $PROJECT_NAME"

# Tuist Templates 경로 찾기
echo ""
echo "🔍 Tuist 설치 경로를 찾는 중..."

TEMPLATES_DIR=$(find_tuist_path)
FIND_TUIST_EXIT_CODE=$?

if [ $FIND_TUIST_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Tuist를 찾을 수 없습니다."
    echo "   다음 중 하나의 방법으로 Tuist를 설치해주세요:"
    echo "   - Homebrew: brew install tuist"
    echo "   - Mise: mise install tuist@latest"
    echo "   - 공식 설치: curl -Ls https://install.tuist.io | bash"
    exit 1
fi

TARGET_DIR="$TEMPLATES_DIR/$PROJECT_NAME"

echo ""
echo "📋 설치 정보:"
echo "   소스 디렉터리: $CURRENT_DIR"
echo "   대상 디렉터리: $TARGET_DIR"

# 대상 디렉터리가 이미 존재하는지 확인
if [ -d "$TARGET_DIR" ]; then
    echo ""
    echo "⚠️  템플릿이 이미 존재합니다: $TARGET_DIR"
    read -p "덮어쓰시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 설치가 취소되었습니다."
        exit 1
    fi
    
    echo "🗑️  기존 템플릿을 삭제합니다..."
    rm -rf "$TARGET_DIR"
fi

# 프로젝트 복사
echo ""
echo "📂 템플릿을 복사하는 중..."

# 복사할 공간이 충분한지 확인 (선택적)
REQUIRED_SPACE=$(du -s "$CURRENT_DIR" 2>/dev/null | cut -f1)
TEMPLATES_PARENT_DIR=$(dirname "$TEMPLATES_DIR")

if [ -d "$TEMPLATES_PARENT_DIR" ]; then
    AVAILABLE_SPACE=$(df "$TEMPLATES_PARENT_DIR" 2>/dev/null | tail -1 | awk '{print $4}')
    
    if [ -n "$REQUIRED_SPACE" ] && [ -n "$AVAILABLE_SPACE" ] && [ "$REQUIRED_SPACE" -gt "$AVAILABLE_SPACE" ]; then
        echo "❌ 디스크 공간이 부족합니다."
        echo "   필요한 공간: ${REQUIRED_SPACE}KB"
        echo "   사용 가능한 공간: ${AVAILABLE_SPACE}KB"
        exit 1
    fi
fi

# 복사 실행
if cp -R "$CURRENT_DIR" "$TARGET_DIR" 2>/dev/null; then
    echo "✅ 템플릿이 성공적으로 설치되었습니다!"
    
    # 복사된 파일 개수 확인
    COPIED_FILES=$(find "$TARGET_DIR" -type f | wc -l | tr -d ' ')
    echo "📄 복사된 파일 개수: $COPIED_FILES"
    
    echo ""
    echo "🎉 설치 완료:"
    echo "   템플릿 위치: $TARGET_DIR"
    echo ""
    echo "💡 사용 방법:"
    echo "   tuist init --template $PROJECT_NAME"
    echo ""
    echo "🔍 템플릿 확인:"
    echo "   tuist template list"
    echo ""
else
    echo "❌ 템플릿 복사 중 오류가 발생했습니다."
    echo "   가능한 원인:"
    echo "   - 권한 부족 (sudo 권한이 필요할 수 있습니다)"
    echo "   - 디스크 공간 부족"
    echo "   - 대상 경로에 접근할 수 없음"
    echo ""
    echo "💡 해결 방법:"
    echo "   sudo $0  # 관리자 권한으로 실행"
    exit 1
fi