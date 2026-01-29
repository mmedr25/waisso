const produits = [
    { nom: "Pizza Margherita", type: "pizza", prix: 12 },
    { nom: "Coca-Cola", type: "boisson", prix: 3 },
    { nom: "Tiramisu", type: "dessert", prix: 6 },
];

function appliquerRemise(produits, typeCible, tauxRemise) {
    for (let i = 0; i <= produits.length; i++) {
        if (produit[i].type === typeCible) {
            produits[j].prix = produits[j].prix * (1 – tauxRemise);
        }
        return produits;
    }

    const resultat = appliqueRemise(produits, "pizza", 0.1);
    console.log("Produits après remise :", resultat);