# C++ 编译器和编译选项
CXX ?= g++
CXXFLAGS ?= -std=c++20 -g -Wall -Wextra -Werror -I.

# 输出目录
OUTPUT_DIR = build

# 所有源文件，假设所有源文件以 stepX_ 开头
SRCS = $(wildcard step*_*.cpp)

# 使用 shell 命令获取 X 最大的文件
MAX_STEP_SRC = $(shell echo $(SRCS) | tr ' ' '\n' | sort -n | tail -n 1)

# 需要链接的依赖库源文件
LIB_SRCS = printer.cpp reader.cpp types.cpp env.cpp error.cpp builtin.cpp evaluator.cpp

# 所有源文件（包括依赖库的源文件）
ALL_SRCS = $(MAX_STEP_SRC) $(LIB_SRCS)

# 对象文件（每个源文件对应一个对象文件）
OBJS = $(ALL_SRCS:%.cpp=$(OUTPUT_DIR)/%.o)

# 默认目标：构建最大 X 的可执行文件
all: $(OUTPUT_DIR)/$(basename $(notdir $(MAX_STEP_SRC)))

# 生成 .o 文件的规则
$(OUTPUT_DIR)/%.o: %.cpp
	mkdir -p $(OUTPUT_DIR)  # 创建输出目录（如果不存在的话）
	${CXX} ${CXXFLAGS} -c $< -o $@

# 生成可执行文件的规则
$(OUTPUT_DIR)/%: $(OBJS)
	${CXX} ${CXXFLAGS} $^ -o $@

# 清理生成的文件
clean:
	rm -rf $(OUTPUT_DIR)

# 重新构建
rebuild: clean all

# 声明伪目标
.PHONY: clean rebuild all
