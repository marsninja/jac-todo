"""TaskFlow - Entry Point.

Combines server-side endpoints with client-side UI.
A modern todo app with hierarchical sub-todos and priorities.
"""

# Import server-side data models and walkers
sv {
    import from endpoints { Todo, AddTodo, ListTodos, ToggleTodo, DeleteTodo, MealToIngredients }
}

# Client-side UI
cl {
    import from frontend { app as ClientApp }

    def:pub app -> any {
        return
            <ClientApp />;
    }
}
