-include .env

.PHONY: all install build test clean format snapshot anvil deploy-local deploy-sepolia verify help

all: clean install build

# 安装依赖项
install:
	forge install

# 编译合约
build:
	forge build

# 运行测试
test:
	forge test

# 运行指定测试文件
test-file:
	forge test --match-path $(file)

# 进行测试覆盖率分析
coverage:
	forge coverage

# 清理生成的文件
clean:
	forge clean

# 格式化代码
format:
	forge fmt

# 创建gas快照
snapshot:
	forge snapshot

# 启动本地区块链
anvil:
	anvil

# 部署到本地节点
deploy-local:
	forge script script/Deploy.s.sol:Deploy --fork-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# 部署到Sepolia测试网(需要.env文件配置)
deploy-sepolia:
	forge script script/Deploy.s.sol:Deploy --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

# 部署到Sepolia测试网并验证合约
deploy-sepolia-verify:
	forge script script/Deploy.s.sol:Deploy --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

# 检查合约大小
check-size:
	forge build --sizes

# 帮助信息
help:
	@echo "可用命令:"
	@echo "  make install              - 安装依赖项"
	@echo "  make build                - 编译合约"
	@echo "  make test                 - 运行所有测试"
	@echo "  make test-file file=路径  - 运行指定测试文件"
	@echo "  make coverage             - 生成测试覆盖率报告"
	@echo "  make clean                - 清理生成的文件"
	@echo "  make format               - 格式化代码"
	@echo "  make snapshot             - 创建gas快照"
	@echo "  make anvil                - 启动本地区块链"
	@echo "  make deploy-local         - 部署到本地节点"
	@echo "  make deploy-sepolia       - 部署到Sepolia测试网"
	@echo "  make deploy-sepolia-verify- 部署并验证Sepolia合约"
	@echo "  make check-size           - 检查合约大小"
	@echo ""
	@echo "在部署到Sepolia前，请确保创建.env文件并包含以下内容:"
	@echo "SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_API_KEY"
	@echo "PRIVATE_KEY=YOUR_WALLET_PRIVATE_KEY"
	@echo "ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY"
