"""TaskFlow - Entry Point.

Combines server-side endpoints with client-side UI.
A modern todo app with hierarchical sub-todos and priorities.
"""

# Client-side UI
cl {
    import from frontend { app as ClientApp }

    def:pub app -> any {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="claude-sonnet-4-20250514");

enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, CLOVE, BUNCH }

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}

sem Ingredient.cost = "Estimated cost in JMD";
sem Ingredient.carby = "Will spike glucose";

"""
Generate a shopping list of ingredients needed for a described meal.
"""
def generate_ingredients(meal_description: str) -> list[Ingredient] by llm();

node MealIngredient {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

node Todo {
    has id: str,
        title: str,
        completed: bool = False,
        priority: str = "medium",
        parent_id: str = "";
}

glob todo_counter: int = 0;

walker:priv AddTodo {
    has title: str,
        priority: str = "medium",
        parent_id: str = "";

    can create with Root entry {
        global todo_counter;
        todo_counter += 1;
        new_id = "todo_" + str(todo_counter);
        new_todo = here ++> Todo(
            id=new_id,
            title=self.title,
            completed=False,
            priority=self.priority,
            parent_id=self.parent_id
        );
        if new_todo {
            report new_todo[0];
        }
    }
}

walker:priv ListTodos {
    has todos: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with Todo entry {
        self.todos.append(
            {
                "id": here.id,
                "title": here.title,
                "completed": here.completed,
                "priority": here.priority,
                "parent_id": here.parent_id
            }
        );
    }

    can report_all with Root exit {
        report self.todos;
    }
}

walker:priv ToggleTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can toggle with Todo entry {
        if here.id == self.todo_id {
            here.completed = not here.completed;
            report {"id": here.id, "completed": here.completed};
        }
    }
}

walker:priv DeleteTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can delete with Todo entry {
        if here.id == self.todo_id or here.parent_id == self.todo_id {
            del here;
            report {"deleted": self.todo_id};
        }
    }
}

walker:priv GenerateShoppingList {
    has meal_description: str;

    can generate with Root entry {
        # Clear existing meal ingredients from this user's graph
        visit [-->];
        # Generate new ingredients via LLM
        ingredients = generate_ingredients(self.meal_description);
        result: list = [];
        for ing in ingredients {
            ing_data = {
                "name": ing.name,
                "quantity": ing.quantity,
                "unit": str(ing.unit).split(".")[-1].lower(),
                "cost": ing.cost,
                "carby": ing.carby
            };
            # Persist to user's graph
            here ++> MealIngredient(
                name=ing_data["name"],
                quantity=ing_data["quantity"],
                unit=ing_data["unit"],
                cost=ing_data["cost"],
                carby=ing_data["carby"]
            );
            result.append(ing_data);
        }
        report result;
    }

    can clear_old with MealIngredient entry {
        del here;
    }
}

walker:priv ListMealPlan {
    has ingredients: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with MealIngredient entry {
        self.ingredients.append({
            "name": here.name,
            "quantity": here.quantity,
            "unit": here.unit,
            "cost": here.cost,
            "carby": here.carby
        });
    }

    can report_all with Root exit {
        report self.ingredients;
    }
}

walker:priv ClearMealPlan {
    can collect with Root entry {
        visit [-->];
    }

    can clear with MealIngredient entry {
        del here;
        report {"cleared": True};
    }
}
