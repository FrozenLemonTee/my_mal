#include <string>
#include <utility>
#include "iostream"

// todo
std::string READ(std::string input){
    return input;
}
// todo
std::string EVAL(std::string input) {
    return input;
}
// todo
std::string PRINT(std::string input) {
    return READ(EVAL(std::move(input)));
}

int main(){
    while(true){
        std::cout << "user> ";
        std::string input;
        if (!std::getline(std::cin, input)) {
            std::cout << std::endl;
            break;
        }
        std::cout << PRINT(input) << std::endl;
    }

    return 0;
}
