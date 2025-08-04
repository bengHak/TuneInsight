#!/bin/bash

# 프로젝트 생성 및 빌드 스크립트
# 사용법: ./Scripts/build.sh

set -e

echo "🚀 Tuist 프로젝트 생성 중..."
tuist generate --no-open

echo "🔨 프로젝트 빌드 중..."
tuist build

echo "✅ 빌드 완료!"
