# NFT活动平台智能合约

本项目是一个基于以太坊的NFT活动平台智能合约，使用Foundry框架开发。该平台允许创建和管理NFT奖励活动，支持自动化销毁NFT和退还ETH。

## 项目特点

- **NFT铸造**：支持创建和铸造定制化NFT
- **活动管理**：设置活动时间、参与条件和奖励分配
- **自动处理**：集成Chainlink自动化功能，在活动结束后自动销毁队伍NFT并退还ETH
- **权限控制**：完善的权限管理机制
- **可扩展性**：模块化设计，易于扩展

## 技术栈

- Solidity ^0.8.13
- Foundry
- OpenZeppelin合约
- Chainlink

## 项目结构

```
src/
├── NFTFactory.sol       # 主要NFT工厂合约
├── interfaces/          # 接口定义
├── utils/               # 工具合约
test/
├── NFTFactory.t.sol     # 测试用例
script/
├── Deploy.s.sol         # 部署脚本
```

## 安装与设置

### 前置条件

- 安装[Foundry](https://book.getfoundry.sh/getting-started/installation)

### 安装依赖

```shell
$ forge install
```

## 编译合约

```shell
$ forge build
```

## 运行测试

```shell
$ forge test
```

## 部署合约

在部署之前，请创建`.env`文件并设置以下环境变量：

```
PRIVATE_KEY=your_private_key
RPC_URL=your_rpc_url
ETHERSCAN_API_KEY=your_etherscan_api_key
```

然后运行以下命令进行部署：

```shell
$ source .env
$ make deploy-sepolia
```

或手动部署：

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 配置Chainlink Automation

合约部署后，需要在Chainlink Automation服务上注册以启用活动结束后自动销毁队伍NFT并退还ETH的功能：

1. 访问[Chainlink Automation](https://automation.chain.link/)并连接钱包
2. 点击"Register new Upkeep"
3. 选择"Custom Logic"
4. 填写以下信息：
   - Upkeep名称：`NFTFactoryAutomation`（或您喜欢的任何名称）
   - 合约地址：部署的`NFTFactory`合约地址
   - Gas限制：500000
   - 启动资金：2-5 LINK（取决于您预期的运行频率）
5. 确认并支付LINK代币注册费用
6. 完成注册后，Chainlink节点将定期调用您合约的`checkUpkeep`函数，并在活动结束时触发`performUpkeep`自动销毁队伍NFT并退还ETH

### 验证Automation设置

1. 在Chainlink Automation控制面板上，找到您注册的Upkeep
2. 查看"History"选项卡，确认是否有执行记录
3. 您也可以通过合约事件日志查看自动销毁和退款的执行情况

## 使用Makefile

项目包含Makefile以简化操作：

- `make build`: 编译合约
- `make test`: 运行测试
- `make deploy-sepolia`: 部署到Sepolia测试网
- `make verify CONTRACT=<合约地址> NETWORK=sepolia`: 验证合约

## 许可证

MIT
