#!/bin/bash

# 테스트 실행 스크립트
# 사용법: ./Scripts/test.sh

set -e

echo "🧪 테스트 실행 중..."
tuist test

echo "✅ 테스트 완료!"
