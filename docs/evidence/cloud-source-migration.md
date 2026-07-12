# Concordia 源码迁移证据

## 输入

- GitHub公开仓：`https://github.com/jensenojs/Concordia`
- CNB candidate：`https://cnb.cool/gevico.online/jensen/concordia`
- 固定Type-2功能基线：`e680a2ecc9cf10a06e664c5b599e23b72582d24b`
- 初始公开refs：`tmatmul@4f5ca249...`、`type2-fixed-1p5b@e680a2e...`，无tag
- 初始ref map SHA256：`722cc88b1d815965f31adec975ab3a8deb477e69beb790716405fed547dacb30`

## 迁移过程

迁移从GitHub公开refs开始，没有把旧本地checkout的分支名`tmatmul`及其不同HEAD写回公开ref。仓内控制文件建立在`type2-fixed-1p5b`上，commit为`2ddea176b46e5d51fcf32caad14337b40ccd7fd4`；该commit先进入CNB，再以同SHA进入GitHub，没有force-push。

双端fresh mirror使用已有本地对象作为只读传输加速源并在clone后dissociate；两个mirror均非shallow，`git fsck --full`返回0，最终两个ref逐字节一致，ref map SHA256均为`9f8c14c377cc63f4b4ad0286c06373560b0bf624e91e3d6134dbcbe73d133aae`。

CNB source probe：

- SN：[`cnb-7jg-1jtatr13d`](https://cnb.cool/gevico.online/jensen/concordia/-/build/logs/cnb-7jg-1jtatr13d)
- exact commit：`2ddea176b46e5d51fcf32caad14337b40ccd7fd4`
- runner：amd64、2 CPU、4 GiB
- 结果：`source_probe=pass`、`shallow=false`、`worktree_clean=true`

## 证明范围

该证据证明CNB与GitHub保存相同Concordia superproject refs及可达对象，且CNB任务能获得非shallow、clean的exact checkout。它不证明两个gitlink已恢复，不证明LLVM/Rust/CUDA构建，不证明NVIDIA backend、Type-2、固定1.5B、Kimi correctness或tps。

包含本文件的后续commit只增加迁移说明。最终生效source commit与cutover commit由`cxl-lab`有效控制ref记录。
