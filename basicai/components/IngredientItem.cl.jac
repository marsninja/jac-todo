"""Ingredient item component for the shopping list."""

def:pub IngredientItem(ingredient: dict) -> any {
    unitLabel = ingredient.unit or "";

    return
        <div className="ingredient-item">
            <div className="ingredient-info">
                <span className="ingredient-name">
                    {ingredient.name}
                </span>
                <span className="ingredient-qty">
                    {ingredient.quantity}{" "}{unitLabel}
                </span>
            </div>
            <div className="ingredient-meta">
                {(
                    <span className="carb-badge">
                        Carbs
                    </span>
                )
                if ingredient.carby
                else None}
                <span className="cost-label">
                    J${ingredient.cost.toFixed(0)}
                </span>
            </div>
        </div>;
}
