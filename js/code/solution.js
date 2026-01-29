const produits = [
    { nom: "Pizza Margherita", type: "pizza", prix: 12 },
    { nom: "Coca-Cola", type: "boisson", prix: 3 },
    { nom: "Tiramisu", type: "dessert", prix: 6 },
];

function appliquerRemise(produits, typeCible, tauxRemise) {
    for (let i = 0; i <= produits.length; i++) {
        if (produits[i].type === typeCible) {
            produits[i].prix = produits[i].prix * (1 - tauxRemise);
        }

        return produits;
    }
}

const resultat = appliquerRemise(produits, "pizza", 0.1);
console.log("Produits après remise :", resultat);