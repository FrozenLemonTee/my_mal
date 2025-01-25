#include "types.h"

#include <regex>
#include <utility>

auto MalType::isInt(const std::string& token) -> bool {
    return std::regex_match(token, std::regex("^[-+]?[0-9]{1,19}$"));
}

auto MalType::isNil(const std::string& token) -> bool {
    return token == "nil";
}

auto MalType::isBool(const std::string& token) -> bool {
    return token == "true" || token == "false";
}

auto MalType::isChar(const std::string& token) -> bool {
    return token.size() == 1;
}

auto MalNil::to_string() -> std::string {
    return {};
}

MalBool::MalBool(const bool val) : val_(val) {}

auto MalBool::to_string() -> std::string {
    return val_ ? "true" : "false";
}

MalInt::MalInt(const int64_t val) : val_(val) {}

auto MalInt::to_string() -> std::string {
    return std::to_string(this->val_);
}

MalChar::MalChar(const char val) : val_(val) {}

auto MalChar::to_string() -> std::string {
    return std::to_string(this->val_);
}

MalSymbol::MalSymbol(std::string name) : name_(std::move(name)) {}

auto MalSymbol::to_string() -> std::string {
    return name_;
}

MalList::MalList(std::vector<MalType*> elements)
    : elements_(std::move(elements)) {}

auto MalList::to_string() -> std::string {
    std::stringstream ss;
    ss << "(";
    bool first = true;
    for (const auto element : elements_) {
        ss << element->to_string();
        if (first) {
            ss << " ";
            first = false;
        }
    }
    ss << ")";
    return ss.str();
}

MalList::~MalList() {
    for (const auto e: this->elements_) {
        delete e;
    }
}
