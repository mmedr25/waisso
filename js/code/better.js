// change to english

const products = [
    { name: "Pizza Margherita", type: "pizza", price: 12 },
    { name: "Coca-Cola", type: "boisson", price: 3 },
    { name: "Tiramisu", type: "dessert", price: 6 },
];

function applyDiscount(products, type, discountRate) {
    // a map method for a cleaner code. 
    // I added the old price "oldPrice" because it can always be handle to have
    return products.map(item => {
        // you can also lowercase the compared values
        if (item.type !== type) return item

        return {
            ...item,
            oldPrice: item.price,
            price: item.price * (1 - discountRate)
        }
        
    })
}

const result = applyDiscount(products, "pizza", 0.1);
console.log("products after discount:", result);