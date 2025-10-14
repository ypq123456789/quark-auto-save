# 🔄 切换到官方 Docker 镜像指南

## 🎉 恭喜！PR 已合并

你的 PR 已经被官方合并并发布新版本了！现在可以切换到官方 Docker 镜像。

---

## 🚀 VPS 切换步骤

### 1. 连接到 VPS

```bash
ssh root@your-vps-ip
```

### 2. 备份当前配置（可选但推荐）

```bash
# 备份配置文件
docker cp quark-auto-save:/app/config /root/config_backup_$(date +%Y%m%d)

# 或者直接备份本地配置目录
cp -r /root/quark-auto-save/config /root/config_backup_$(date +%Y%m%d)
```

### 3. 停止并删除当前容器

```bash
# 停止容器
docker stop quark-auto-save

# 删除容器
docker rm quark-auto-save
```

### 4. 拉取最新官方镜像

```bash
# 拉取最新镜像
docker pull soulteary/quark-auto-save:latest

# 或者拉取指定版本（如果有版本号）
# docker pull soulteary/quark-auto-save:v0.x.x
```

### 5. 启动官方镜像

```bash
docker run -d \
  --name quark-auto-save \
  --restart unless-stopped \
  -p 5005:5005 \
  -v /root/quark-auto-save/config:/app/config \
  -e TZ=Asia/Shanghai \
  -e TASK_TIMEOUT=1800 \
  soulteary/quark-auto-save:latest
```

### 6. 验证运行状态

```bash
# 查看容器状态
docker ps | grep quark-auto-save

# 查看日志
docker logs -f quark-auto-save
```

应该看到类似这样的日志：
```
[INFO] >>> 重载调度器
[INFO] 调度状态: 运行
[INFO] 定时规则: */5 10-14,18-23,0 * * *
[INFO] 现有任务: [<Job (id=./quark_auto_save.py name=run_python)>]
```

---

## 🧹 清理旧镜像（可选）

如果一切正常，可以清理旧的自建镜像：

```bash
# 查看所有镜像
docker images

# 删除之前自建的镜像
docker rmi quark-auto-save:fixed

# 删除悬空镜像
docker image prune -f
```

---

## ✅ 验证修复生效

### 检查调度器参数

在日志中应该能看到：
- ✅ 任务每5分钟正常执行
- ✅ 每次执行2-3秒完成
- ❌ 不再出现 "skipped: maximum number of running instances reached" 警告

### 检查版本信息

访问 Web UI：`http://your-vps-ip:5005`

在页面底部应该能看到最新的版本号。

---

## 🔍 故障排除

### 如果拉取镜像失败

```bash
# 检查网络
ping docker.io

# 尝试使用镜像加速器
docker pull registry.cn-hangzhou.aliyuncs.com/soulteary/quark-auto-save:latest
```

### 如果配置丢失

```bash
# 恢复备份
cp -r /root/config_backup_20241014/* /root/quark-auto-save/config/

# 重启容器
docker restart quark-auto-save
```

### 如果任务不执行

```bash
# 检查配置文件
cat /root/quark-auto-save/config/quark_config.json

# 检查权限
ls -la /root/quark-auto-save/config/
```

---

## 📊 对比：自建 vs 官方镜像

| 对比项 | 自建镜像 | 官方镜像 |
|--------|---------|---------|
| 功能 | ✅ 包含修复 | ✅ 包含修复 |
| 更新频率 | 手动更新 | 自动获取更新 |
| 稳定性 | ✅ 已测试 | ✅ 官方维护 |
| 社区支持 | 有限 | ✅ 完整支持 |
| 推荐程度 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 🎯 一键切换脚本

创建并执行以下脚本：

```bash
cat > /root/switch_to_official.sh << 'EOF'
#!/bin/bash
echo "🔄 切换到官方 Docker 镜像"
echo "================================"

# 备份配置
echo "📁 备份配置文件..."
docker cp quark-auto-save:/app/config /root/config_backup_$(date +%Y%m%d) 2>/dev/null || cp -r /root/quark-auto-save/config /root/config_backup_$(date +%Y%m%d)

# 停止并删除容器
echo "🛑 停止当前容器..."
docker stop quark-auto-save
docker rm quark-auto-save

# 拉取最新镜像
echo "📥 拉取官方最新镜像..."
docker pull soulteary/quark-auto-save:latest

# 启动新容器
echo "🚀 启动官方镜像..."
docker run -d \
  --name quark-auto-save \
  --restart unless-stopped \
  -p 5005:5005 \
  -v /root/quark-auto-save/config:/app/config \
  -e TZ=Asia/Shanghai \
  -e TASK_TIMEOUT=1800 \
  soulteary/quark-auto-save:latest

echo "✅ 切换完成！"
echo "📝 查看日志: docker logs -f quark-auto-save"
echo "🌐 访问 Web UI: http://$(curl -s ifconfig.me):5005"
EOF

chmod +x /root/switch_to_official.sh
/root/switch_to_official.sh
```

---

**现在就可以执行切换了！你的修复已经包含在官方镜像中。** 🎉
