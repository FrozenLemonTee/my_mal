# C++ 编译器和编译选项
CXX ?= g++
CXXFLAGS ?= -g -Wall -Wextra -Werror

# 输出目录
OUTPUT_DIR = build

# 所有源文件，假设所有源文件以 stepX_ 开头
SRCS = $(wildcard step*_*.cpp)

# 对象文件（每个源文件对应一个对象文件）
OBJS = $(SRCS:%.cpp=$(OUTPUT_DIR)/%.o)

# 默认目标：构建所有可执行文件
all: $(SRCS:%.cpp=$(OUTPUT_DIR)/%)

# 生成 .o 文件的规则
$(OUTPUT_DIR)/%.o: %.cpp
	@mkdir -p $(OUTPUT_DIR)  # 创建输出目录（如果不存在的话）
	@${CXX} ${CXXFLAGS} -c $< -o $@

# 生成可执行文件的规则
$(OUTPUT_DIR)/%: $(OUTPUT_DIR)/%.o
	@${CXX} ${CXXFLAGS} $< -o $@

# 清理生成的文件
clean:
	@rm -rf $(OUTPUT_DIR)

# 重新构建
rebuild: clean all

# 声明伪目标
.PHONY: clean rebuild all
