"""Todo App - Server-Side Data Layer with sub-todos and priorities."""

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="claude-sonnet-4-20250514");

obj Ingredient {
    has name: str;
    has cost: float;
    has carby: bool;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "Will spike glucose";

"""
Generate a shopping list of ingredients needed for a described meal.
"""
def generate_ingredients(meal_description: str) -> list[Ingredient] by llm();

node Todo {
    has id: str,
        title: str,
        completed: bool = False,
        priority: str = "medium",
        parent_id: str = "";
}

walker:priv AddTodo {
    has title: str,
        priority: str = "medium",
        parent_id: str = "";

    can create with `root entry {
        new_id = str(uuid4());
        new_todo = here ++> Todo(
            id=new_id,
            title=self.title,
            completed=False,
            priority=self.priority,
            parent_id=self.parent_id
        );
        report new_todo[0];
    }
}

walker:priv ListTodos {
    has todos: list = [];

    can collect with `root entry {
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

    can report_all with `root exit {
        report self.todos;
    }
}

walker:priv ToggleTodo {
    has todo_id: str;

    can search with `root entry {
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

    can search with `root entry {
        visit [-->];
    }

    can delete with Todo entry {
        if here.id == self.todo_id or here.parent_id == self.todo_id {
            del here;
            report {"deleted": self.todo_id};
        }
    }
}

walker:priv MealToIngredients {
    has meal_description: str;

    can process with `root entry {
        ingredients = generate_ingredients(self.meal_description);
        total_cost: float = 0.0;
        for ingredient in ingredients {
            new_id = str(uuid4());
            title = f"{ingredient.name} (${ingredient.cost:.2f})";
            here ++> Todo(
                id=new_id,
                title=title,
                completed=False,
                priority="medium",
                parent_id=""
            );
            total_cost += ingredient.cost;
        }
        todos = root spawn ListTodos();
        report {
            "meal": self.meal_description,
            "ingredients_added": todos,
            "total_cost": total_cost
        };
    }
}
