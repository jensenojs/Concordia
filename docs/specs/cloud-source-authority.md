# Concordia 云端源码权威

## 目标与证据层

BR3。本切片把Concordia superproject公开历史迁入CNB组件仓，并建立独立checkout可理解的source probe与候选NVIDIA build输入。它服务后续Concordia artifact、Type-2固定1.5B、Kimi correctness与tps，但只关闭源码权威。

```text
GitHub primary
  → CNB candidate保存声明refs
  → migration commit同时进入CNB与GitHub
  → 双端fresh mirror/ref map/fsck
  → CNB exact SHA source probe
  → cxl-lab单commit cutover
  → CNB primary / GitHub mirror
```

## 目标结构

```text
concordia/
├── AGENTS.md
├── docs/specs/cloud-source-authority.md
├── manifests/build-profile.json
├── scripts/verify_source_checkout.sh
└── .cnb.yml
```

公开ref集合在迁移开始时为两个heads：`tmatmul@4f5ca249...`和`type2-fixed-1p5b@e680a2ecc9cf10a06e664c5b599e23b72582d24b`，无tag；规范化ref map SHA256为`722cc88b1d815965f31adec975ab3a8deb477e69beb790716405fed547dacb30`。migration commit必须建立在`type2-fixed-1p5b`上，并保持功能基线可达。

## 边界

“完整历史”只指上述superproject refs及其可达对象。`ext/llvm-project`与`ext/cuda-tile`gitlink不在本次证明范围。候选profile记录当前系统LLVM 21、NVIDIA feature和单并发入口；真实CNB build前仍需验证工具镜像、Cargo.lock、动态依赖和输出文件图。

source probe拒绝shallow和dirty checkout，不fetch、不初始化submodule、不build。迁移证据不得关闭Concordia build、CUDA语义、Type-2、固定1.5B、Kimi或tps。

## 验收与回滚

- CNB与GitHub heads/tags ref map逐字节一致，fresh mirrors非shallow，`git fsck --full`通过。
- migration commit包含本结构，`e680a2e`可达，CNB exact SHA probe输出`source_probe=pass`。
- `cxl-lab`单个cutover commit更新Concordia URL/commit；cutover前GitHub仍是primary。
- 回滚恢复上一个`cxl-lab` source-lock commit；不改写或force-push两端历史。
