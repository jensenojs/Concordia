# Concordia Scripts

本文件约束`scripts/`。组件职责、NVIDIA feature边界和候选profile见`../AGENTS.md`与`../docs/specs/`。

```text
verify_source_checkout.sh  验证exact source、non-shallow和clean checkout
build_component.sh         按Cargo.lock与profile构建并stage libnvcuda.so
component_artifact.py      生成/验证通用组件文件manifest与安全归档
publish_component.sh       确定性归档并发布到本仓registry
pull_component.sh          只按digest恢复并重复ELF/export检查
```

`build_component.sh`只能使用`--features nvidia --no-default-features --locked -j1`及profile声明环境。不得启用Intel默认feature、初始化llvm-project/cuda-tile、构造缺文件stub fallback或修改Cargo.lock。publish/pull是仅有网络边界，认证由CNB环境提供。

build证明固定工具链能够生成backend文件；fresh pull证明文件可恢复。任何脚本都不证明QEMU加载成功、Type-2 compute、固定1.5B、Kimi或性能。
