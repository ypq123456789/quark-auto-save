#!/bin/bash
# 一键切换到修复版本 Docker 镜像脚本

echo "🔧 部署修复版本（Python 3.13兼容）"
echo "=================================================="
echo ""

# 检查当前容器
if docker ps | grep -q quark-auto-save; then
    echo "📋 当前运行的镜像："
    docker ps --filter name=quark-auto-save --format "   {{.Image}}"
    echo ""
fi

echo "🔄 开始部署修复版本..."
echo ""

# 备份配置
echo "1️⃣ 备份配置文件..."
BACKUP_DIR="/root/config_backup_$(date +%Y%m%d_%H%M%S)"
if docker cp quark-auto-save:/app/config "$BACKUP_DIR" 2>/dev/null; then
    echo "   ✅ 配置已备份到: $BACKUP_DIR"
elif [ -d "/root/quark-auto-save/config" ]; then
    cp -r /root/quark-auto-save/config "$BACKUP_DIR"
    echo "   ✅ 配置已备份到: $BACKUP_DIR"
else
    echo "   ⚠️ 未找到配置目录，请确认路径"
fi
echo ""

# 停止并删除容器
echo "2️⃣ 停止当前容器..."
docker stop quark-auto-save >/dev/null 2>&1 && echo "   ✅ 容器已停止" || echo "   ℹ️ 容器未运行"
docker rm quark-auto-save >/dev/null 2>&1 && echo "   ✅ 容器已删除" || echo "   ℹ️ 容器不存在"
echo ""

# 克隆修复版本代码
echo "3️⃣ 获取修复版本代码..."
cd /root
if [ -d "quark-auto-save-fix" ]; then
    rm -rf quark-auto-save-fix
fi

if git clone -b fix-scheduler-params https://github.com/ypq123456789/quark-auto-save.git quark-auto-save-fix; then
    echo "   ✅ 代码克隆成功"
else
    echo "   ❌ 代码克隆失败，请检查网络或GitHub访问"
    exit 1
fi
echo ""

# 构建镜像
echo "4️⃣ 构建修复版本镜像..."
cd /root/quark-auto-save-fix
if docker build -t quark-auto-save:python313-fix .; then
    echo "   ✅ 镜像构建成功"
else
    echo "   ❌ 镜像构建失败"
    exit 1
fi
echo ""

# 启动新容器
echo "5️⃣ 启动修复版本容器..."
if docker run -d \
  --name quark-auto-save \
  --restart unless-stopped \
  -p 5005:5005 \
  -v /root/quark-auto-save/config:/app/config \
  -e TZ=Asia/Shanghai \
  -e TASK_TIMEOUT=1800 \
  quark-auto-save:python313-fix >/dev/null; then
    echo "   ✅ 容器启动成功"
else
    echo "   ❌ 容器启动失败"
    exit 1
fi
echo ""

# 等待容器启动
echo "6️⃣ 等待服务启动..."
sleep 3
echo ""

# 显示状态
echo "📊 当前状态："
docker ps --filter name=quark-auto-save --format "   容器: {{.Names}} | 镜像: {{.Image}} | 状态: {{.Status}}"
echo ""

# 检查日志
echo "📝 最新日志："
docker logs --tail 10 quark-auto-save | sed 's/^/   /'
echo ""

echo "✅ 修复版本部署完成！"
echo ""
echo "🔍 查看详细日志: docker logs -f quark-auto-save"
echo "🌐 访问 Web UI: http://$(curl -s ifconfig.me 2>/dev/null || echo 'your-vps-ip'):5005"
echo "📊 监控容器: docker stats quark-auto-save"
echo ""
echo "⚡ 修复内容："
echo "   • Python 3.13 兼容性修复"
echo "   • TimeoutExpired.process 属性兼容处理"
echo "   • 调度器参数优化保持不变"
