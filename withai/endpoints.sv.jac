"""Todo App - Server-Side Data Layer with sub-todos and priorities."""

import from byllm.lib { Model }

glob llm = Model(model_name="claude-sonnet-4-20250514");

obj Ingredient {
    has name: str;
    has cost: float;
    has carby: bool;
}

sem Ingredient. cost= "Estimated cost in USD";
sem Ingredient. carby= "Will spike glucose";

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

glob todo_counter: int = 0;

walker:priv AddTodo {
    has title: str,
        priority: str = "medium",
        parent_id: str = "";

    can create with `root entry {
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
            report new_todo[0] ;
        }
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
        report self.todos ;
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
            report {"id": here.id, "completed": here.completed} ;
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
            del here ;
            report {"deleted": self.todo_id} ;
        }
    }
}

walker:priv MealToIngredients {
    has meal_description: str;

    can process with `root entry {
        global todo_counter;
        ingredients = generate_ingredients(self.meal_description);
        added_todos: list = [];
        total_cost: float = 0.0;
        for ingredient in ingredients {
            todo_counter += 1;
            new_id = "todo_" + str(todo_counter);
            title = f"{ingredient.name} (${ingredient.cost:.2f})";
            new_todo = here ++> Todo(
                id=new_id,
                title=title,
                completed=False,
                priority="medium",
                parent_id=""
            );
            if new_todo {
                added_todos.append(
                    {
                        "id": new_todo[0].id,
                        "title": new_todo[0].title,
                        "completed": new_todo[0].completed,
                        "priority": new_todo[0].priority,
                        "parent_id": new_todo[0].parent_id,
                        "cost": ingredient.cost,
                        "carby": ingredient.carby
                    }
                );
                total_cost += ingredient.cost;
            }
        }
        report {
            "meal": self.meal_description,
            "ingredients_added": added_todos,
            "total_cost": total_cost
        } ;
    }
}
