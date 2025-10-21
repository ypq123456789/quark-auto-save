#!/bin/bash
echo "🔄 部署修复版本到VPS"
echo "================================"

# 停止当前容器
echo "🛑 停止当前容器..."
docker stop quark-auto-save 2>/dev/null || true
docker rm quark-auto-save 2>/dev/null || true

# 备份配置
echo "📁 备份配置文件..."
cp -r /root/quark-auto-save/config /root/config_backup_$(date +%Y%m%d_%H%M) 2>/dev/null || true

# 克隆你的修复版本
echo "📥 克隆修复版本代码..."
cd /root
rm -rf quark-auto-save-fix
git clone -b fix-scheduler-params https://github.com/ypq123456789/quark-auto-save.git quark-auto-save-fix

# 构建新镜像
echo "🔨 构建修复版本镜像..."
cd /root/quark-auto-save-fix
docker build -t quark-auto-save:fix .

# 启动新容器
echo "🚀 启动修复版本容器..."
docker run -d \
  --name quark-auto-save \
  --restart unless-stopped \
  -p 5005:5005 \
  -v /root/quark-auto-save/config:/app/config \
  -e TZ=Asia/Shanghai \
  -e TASK_TIMEOUT=1800 \
  quark-auto-save:fix

echo "✅ 修复版本部署完成！"
echo "📝 查看日志: docker logs -f quark-auto-save"
echo "🌐 访问 Web UI: http://$(curl -s ifconfig.me):5005"
