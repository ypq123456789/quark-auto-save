# 🎯 创建 PR - 一键链接

## 📌 PR 创建链接

**点击这个链接创建 PR：**

```
https://github.com/Cp0204/quark-auto-save/compare/main...ypq123456789:quark-auto-save:fix-scheduler-params?expand=1
```

---

## 📋 PR 信息（自动填充）

提交时会自动使用 commit message，但你可以在描述中补充以下内容：

### 标题（已自动填充）
```
🐛 补充修复:添加 APScheduler 调度器参数，彻底解决任务堆积问题
```

### 描述补充

可以在自动生成的描述后面添加：

```markdown
## 修复前后对比

**修复前的日志（PR #125 之后仍会出现）：**
```
[10-11 13:40:00][INFO] Running job "run_python"
[10-11 13:45:00][WARNING] Execution of job "run_python" skipped: maximum number of running instances reached (1)
[10-11 13:50:00][WARNING] Execution of job "run_python" skipped: maximum number of running instances reached (1)
... (持续 6 小时)
```

**修复后的日志：**
```
[10-12 14:50:02][INFO] >>> 任务执行成功
[10-12 14:50:02][INFO] Job "run_python" executed successfully
[10-12 14:55:00][INFO] Running job "run_python"  ← 后续任务正常执行
[10-12 14:55:02][INFO] >>> 任务执行成功
```

## 技术细节

### APScheduler 参数说明

- **`coalesce=True`**: 当多个任务错过时，只执行一次最新的，不会让所有错过的任务都排队执行
- **`misfire_grace_time=300`**: 如果任务错过超过 5 分钟，直接跳过不执行，避免过期任务堆积
- **`replace_existing=True`**: 重新加载配置时，替换而不是重复添加同 ID 的任务

这些参数是 APScheduler 官方推荐的最佳实践，用于避免任务堆积和调度器阻塞。

## 影响范围

- ✅ 向后兼容，不影响现有功能
- ✅ 无新依赖，仅调整 APScheduler 参数
- ✅ 所有使用定时任务的场景都受益
- ✅ 解决了 PR #125 遗留的调度器堆积问题
```

---

## ✅ 提交步骤

1. **点击上面的链接**
2. **检查改动** - 应该只有 `app/run.py` 一个文件
3. **点击 "Create pull request"**
4. **等待 CI 通过**
5. **等待维护者审核**

---

## 🔍 验证改动

在创建 PR 前，可以先查看改动：

```
https://github.com/ypq123456789/quark-auto-save/commit/1a42301
```

应该显示：
- ✅ 只修改 `app/run.py`
- ✅ +15 行，-1 行

---

**现在点击链接创建 PR 吧！** 🚀
