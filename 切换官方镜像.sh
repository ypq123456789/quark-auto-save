#!/bin/bash
# 一键切换到官方 Docker 镜像脚本

echo "🎉 恭喜！你的 PR 已合并，现在切换到官方镜像"
echo "=================================================="
echo ""

# 检查当前容器
if docker ps | grep -q quark-auto-save; then
    echo "📋 当前运行的镜像："
    docker ps --filter name=quark-auto-save --format "   {{.Image}}"
    echo ""
fi

echo "🔄 开始切换..."
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

# 拉取最新镜像
echo "3️⃣ 拉取官方最新镜像..."
if docker pull cp0204/quark-auto-save:latest; then
    echo "   ✅ 镜像拉取成功"
else
    echo "   ❌ 镜像拉取失败，请检查网络"
    exit 1
fi
echo ""

# 启动新容器
echo "4️⃣ 启动官方镜像..."
if docker run -d \
  --name quark-auto-save \
  --restart unless-stopped \
  -p 5005:5005 \
  -v /root/quark-auto-save/config:/app/config \
  -e TZ=Asia/Shanghai \
  -e TASK_TIMEOUT=1800 \
  cp0204/quark-auto-save:latest >/dev/null; then
    echo "   ✅ 容器启动成功"
else
    echo "   ❌ 容器启动失败"
    exit 1
fi
echo ""

# 等待容器启动
echo "5️⃣ 等待服务启动..."
sleep 3
echo ""

# 显示状态
echo "📊 当前状态："
echo "   容器状态: $(docker inspect --format='{{.State.Status}}' quark-auto-save 2>/dev/null || echo '未知')"
echo "   镜像版本: $(docker inspect --format='{{.Config.Image}}' quark-auto-save 2>/dev/null || echo '未知')"
echo "   端口映射: $(docker port quark-auto-save 2>/dev/null || echo '未知')"
echo ""

# 获取 IP
PUBLIC_IP=$(curl -s --max-time 3 ifconfig.me 2>/dev/null || curl -s --max-time 3 ip.sb 2>/dev/null || echo "your-vps-ip")

echo "✅ 切换完成！"
echo "=================================================="
echo "📝 查看日志: docker logs -f quark-auto-save"
echo "🌐 访问 Web UI: http://$PUBLIC_IP:5005"
echo "📁 配置备份: $BACKUP_DIR"
echo ""
echo "🎯 验证修复是否生效："
echo "   - 任务应该每5分钟执行一次"
echo "   - 不应再出现 'skipped: maximum number of running instances reached' 警告"
echo "   - 每次任务执行应该在2-3秒内完成"
echo ""
echo "现在你运行的是包含你修复的官方版本！🎉"
