Тип Character в языке Swift - это представление одного символа, реализованное в соответствии со стандартом Unicode. В отличие от языков C/C++ или Java, где char представляет собой однобайтовую  единицу, в Swift символ — это расширенный графемный кластер (extended grapheme cluster). Один символ может включать несколько Unicode-скаляров, объединённых алгоритмом сегментации, чтобы соответствовать человеческому восприятию символов.
Swift сознательно отказался от типа char, чтобы поддерживать все языки и письменности мира. Один видимый символ может состоять из нескольких кодовых точек, например буква é может быть представлена как код U+00E9 или комбинация U+0065 + U+0301, а флаг 🇺🇸 - это один Character, но два скалярных значения U+1F1FA и U+1F1F8.
Swift воспринимает все эти комбинации как один Character. Это гарантирует корректное поведение при подсчёте длины строк, срезах и отображении текста.
Тип Character — это составная часть стандартной библиотеки Swift. Он используется внутри String, который является коллекцией значений Character.  
Когда вы итерируете строку
for ch in "Hello! 🐥" {
    print(ch)
}
переменная ch имеет тип Character, и итерация проходит по символам, а не по байтам или кодовым точкам.
строка (String) — это коллекция Character, а каждый Character — это расширенный графемный кластер.
 
Создать Character можно из строки, которая содержит ровно один символ в Unicode.
let exclamation: Character = "!"
let emoji: Character = "🐥"
let letterE: Character = "é"
Если строка содержит более одного символа, инициализация приведёт к ошибке.
Также Character можно получить из выражений:
let a: Character = Character("a".uppercased())
или при обращении к элементам строки:
let firstChar = "Swift".first! // Character("S")
Каждый Character хранит данные в виде одного или нескольких Unicode-скаляров. Swift предоставляет доступ к низкоуровневым представлениям:
let char: Character = "é"

for scalar in String(char).unicodeScalars {
    print(scalar.value)
}
Можно получить кодировку символа в разных формах: utf8, utf16 и unicodeScalars. —.
Эти представления полезны, если нужно работать с сетевыми протоколами, файлами или системами, где требуется конкретная кодировка.
 
Character реализует протоколы Equatable, Comparable и Hashable, поэтому символы можно сравнивать и использовать в коллекциях:
let a: Character = "é"
let b: Character = "é" // визуально то же самое, но другая комбинация скаляров

print(a == b) // true — каноническая эквивалентность Unicode
Swift сравнивает символы по смыслу, а не по бинарному коду.
Также Character реализует CustomStringConvertible и CustomDebugStringConvertible.
 
Swift не использует числовую индексацию для строк. Каждый индекс (String.Index) соответствует началу расширенного графемного кластера. Это означает, что нельзя «встать» посередине символа (внутри комбинации),срезы и операции над строками всегда целостны, комбинирующие символы не могут быть отделены от базовых букв.
let text = "Café" // последняя буква = e + ◌́
print(text.count) // 4 символа, хотя 5 скаляров
Swift корректно считает, что é — один символ.
 
В дополнение к Character в Swift есть тип Unicode.Scalar, который представляет одну кодовую точку Unicode. Можно рассматривать Character как "группу" одного или нескольких Unicode.Scalar.
let scalars = "é".unicodeScalars
for s in scalars {
    print(s)
}
Здесь вы получите или один скаляр U+00E9, или два — U+0065 и U+0301, в зависимости от способа кодирования строки.
Так как String — это коллекция Character, преобразование между ними естественно:
let c: Character = "A"
let s = String(c)       // "A"
let back = s.first!     // Character("A")
Также String поддерживает конкатенацию символов:
let symbol: Character = "!"
let greeting = "Hello" + String(symbol)
 
Character поддерживает литералы Unicode. Можно записывать:
let omega: Character = "\u{03A9}" // Ω
let sparkle: Character = "\u{2728}" // ✨
или использовать эмодзи напрямую:
let smile: Character = "😄"
Swift гарантирует корректную интерпретацию всех Unicode-литералов и их визуально верное отображение.
 
Так как Character реализует Hashable, его можно использовать как ключ в словаре или элемент множества:
var vowels: Set<Character> = ["a", "e", "i", "o", "u"]

if vowels.contains("e") {
    print("Vowel found")
}
Это удобно при текстовом анализе, фильтрации и обработке символов.
 
Для получения текстового описания символа можно использовать:
let c: Character = "🐥"
print(c.description)      // 🐥
print(c.debugDescription) // "🐥"
Свойства description и debugDescription определены в стандартной библиотеке и обеспечивают корректный человекочитаемый вывод.
 
Взаимосвязь с представлениями UTF-8 и UTF-16
Swift предоставляет три способа просмотра строки:
let text = "Hello! 🐥"

for b in text.utf8 {
    print(b)
}

for u16 in text.utf16 {
    print(u16)
}

for ch in text {
    print(ch)
}
Swift соблюдает каноническую эквивалентность Unicode, тоесть Все варианты записи одного и того же символа будут рассматриваться как равные. Благодаря этому сравнение, сортировка и операции над текстом устойчивы и предсказуемы.
Кроме того операции на уровне Character никогда не нарушают структуру Unicode, предотвращая ошибки при разрезании строк и комбинировании символов.
Методы и свойства типа Character в Swift
| Метод / Свойство                                          | Описание                                                                                                                     | Пример использования                                                                               |
| --------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| var description: String                                 | Возвращает человекочитаемое строковое представление символа. Реализуется через CustomStringConvertible.                    | let ch: Character = "🐥"\nprint(ch.description) // 🐥                                     |
| var debugDescription: String                            | Возвращает строку, подходящую для отладки: символ в кавычках. Реализуется через CustomDebugStringConvertible.              |  let ch: Character = "é"\nprint(ch.debugDescription) // "é"                                |
| static func == (lhs: Character, rhs: Character) -> Bool | Проверяет, равны ли два символа. Сравнение основано на канонической эквивалентности Unicode, а не на байтовом представлении. |  let a: Character = "é"\nlet b: Character = "é"\nprint(a == b) // true                    |
| static func < (lhs: Character, rhs: Character) -> Bool  | Сравнение символов по лексикографическому порядку (протокол Comparable).                                                   |  print("a" < "b") // true                                                                  |
| func hash(into hasher: inout Hasher)                    | Позволяет использовать символы в множествах (Set) и словарях (Dictionary) как ключи (протокол Hashable).               |  var vowels: Set<Character> = [\"a\", \"e\", \"i\"]\nprint(vowels.contains(\"e\")) // true |
| var asciiValue: UInt8?                                  | Возвращает ASCII-код символа, если он входит в диапазон 0–127, иначе nil.                                                  |  let c: Character = \"A\"\nprint(c.asciiValue!) // 65                                      |
| var unicodeScalars: String.UnicodeScalarView            | Даёт доступ к низкоуровневым Unicode-скалярам, из которых состоит символ. Полезно для анализа состава графем.                |  for scalar in \"é\".unicodeScalars {\n    print(scalar.value)\n}\n// 101, 769             |
| func uppercased() -> String                             | Возвращает строку, содержащую символ в верхнем регистре. Работает корректно для всех языков.                                 |  let ch: Character = \"ß\"\nprint(ch.uppercased()) // "SS"                                 |
| func lowercased() -> String                             | Возвращает строку с символом в нижнем регистре.                                                                              |  let ch: Character = \"Ä\"\nprint(ch.lowercased()) // "ä"                                  |
| func isWhitespace (через Unicode категории)           | Проверяет, является ли символ пробелом или разделителем. Реализуется косвенно через CharacterSet.whitespaces.              |  let space: Character = \" \"\nprint(space.isWhitespace) // true                           |
| init?(_ s: String)                                      | Инициализатор, создающий символ из строки, если она содержит ровно один графемный кластер.                                   |  let ch = Character(\"é\")\nprint(ch) // é                                                 |
| init(extendedGraphemeClusterLiteral:)                   | Инициализатор литерала — позволяет использовать Character напрямую в виде 'A' или "🐥".                                |  let bird: Character = \"🐥\"                                                              |
| func write<Target>(to target: inout Target)             | Записывает символ в поток вывода (например, файл или TextOutputStream).                                                    | var output = \"\"\nlet ex: Character = \"Ω\"\nex.write(to: &output)\nprint(output) // Ω   |




