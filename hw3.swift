var massive = (1...50).map { _ in Int.random(in: 1...100) }
print("Сгенерированный массив:")
print(massive)
for i in 1..<massive.count {
    let key = massive[i]
    var low = 0
    var high = i - 1
    while low <= high {
        let mid = (low + high) / 2
        if massive[mid] < key {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    let massiveindex = low
    var j = i
    while j > massiveindex {
        massive[j] = massive[j - 1]
        j -= 1
    }
        massive[massiveindex] = key
}
print("Отсортированный массив:")
print(massive)
