#ifndef TYPES_H
#define TYPES_H
#include <string>
#include <vector>

class MalType {
    public:
        static bool isInt(const std::string& token);
        static bool isNil(const std::string& token);
        static bool isBool(const std::string& token);
        static bool isChar(const std::string& token);

        virtual ~MalType() = 0;
        virtual std::string to_string() = 0;
};

class MalAtom : public MalType {
    public:
        ~MalAtom() override = 0;
};

class MalStruct : public MalType {
    public:
        ~MalStruct() override = 0;
};

class MalNil final : public MalAtom {
    public:
        std::string to_string() override;
};

class MalBool final : public MalAtom {
        bool val_;
    public:
        explicit MalBool(bool val);
        std::string to_string() override;
};

class MalInt final : public MalAtom {
        int64_t val_;
    public:
        explicit MalInt(int64_t val);
        std::string to_string() override;
};

class MalChar final : public MalAtom {
        char val_;
    public:
        explicit MalChar(char val);
        std::string to_string() override;
};

class MalSymbol final : public MalAtom {
        std::string name_;
    public:
        explicit MalSymbol(std::string name);
        std::string to_string() override;
};

class MalList final : public MalStruct {
        std::vector<MalType*> elements_;

    public:
    explicit MalList(std::vector<MalType*> elements);

    std::string to_string() override;
    ~MalList() override;
};

#endif //TYPES_H
