#include "reader.h"

#include <utility>
#include <bits/regex.h>

auto Reader::tokenize(std::string input) -> std::vector<std::string> {
    std::vector<std::string> tokens;
    const std::regex tokens_pattern(token_pattern);
    const std::sregex_iterator it_begin(input.begin(), input.end(), tokens_pattern);
    const std::sregex_iterator it_end{};
    for (auto it = it_begin; it != it_end; ++it) {
        tokens.emplace_back(it->str());
    }
    return tokens;
}

auto Reader::read_str(std::string input) -> MalType* {
    const auto tokens = tokenize(std::move(input));
    Reader reader(tokens, 0);
    return read_form(reader);
}

auto Reader::read_form(Reader &reader) -> MalType* {
    const std::string token = reader.next();
    if (token == "(") {
        return read_list(reader);
    }

    return read_atom(reader);
}

auto Reader::read_list(Reader &reader) -> MalList* {
    std::vector<MalType*> list;
    while (reader.hasNext()) {
        if (std::string token = reader.peek(); token == ")") {
            reader.next();
            break;
        }

        list.emplace_back(read_form(reader));
    }
    return new MalList(list);
}

auto Reader::read_atom(Reader &reader) -> MalAtom* {
    const auto token = reader.next();
    if (MalType::isInt(token)) {
        return new MalInt(std::stoll(token));
    }
    if (MalType::isNil(token)) {
        return new MalNil();
    }
    if (MalType::isBool(token)) {
        return new MalBool(token == "true");
    }
    if (MalType::isChar(token)) {
        new MalChar(token[0]);
    }

    return new MalSymbol(token);
}

Reader::Reader(std::vector<std::string> tokens, const size_t pos)
    : tokens_(std::move(tokens)), pos_(pos) {}

auto Reader::peek() const -> std::string {
    return tokens_[pos_];
}

auto Reader::next() -> std::string {
    if (!this->hasNext())
        return {};

    auto token = this->peek();
    ++pos_;
    return token;
}

auto Reader::hasNext() const -> bool {
    return pos_ < tokens_.size();
}
