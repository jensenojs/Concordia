# Concordia Scripts

本文件约束`scripts/`。组件职责、NVIDIA feature边界和候选profile见`../AGENTS.md`与`../docs/specs/`。

```text
verify_source_checkout.sh  验证exact source、non-shallow和clean checkout
restore_required_gitlink.sh 只恢复profile声明的llvm-sys稀疏子树
build_component.sh         按Cargo.lock与profile构建并stage libnvcuda.so
component_artifact.py      生成/验证通用组件文件manifest与安全归档
publish_component.sh       确定性归档并发布到本仓registry
pull_component.sh          只按digest恢复并重复ELF/export检查
```

`build_component.sh`只能使用`--features nvidia --no-default-features --locked -j1`及profile声明环境。Cargo的`llvm_zluda`仍依赖gitlink中的`llvm-sys`Rust crate，因此允许按exact gitlink恢复该稀疏子树；不得初始化完整LLVM源码或cuda-tile。不得启用Intel默认feature、构造缺文件stub fallback或修改Cargo.lock。源码网络访问仅限声明gitlink，registry网络访问仅限publish/pull。

build证明固定工具链能够生成backend文件；fresh pull证明文件可恢复。任何脚本都不证明QEMU加载成功、Type-2 compute、固定1.5B、Kimi或性能。
