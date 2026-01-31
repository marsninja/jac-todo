"""Implementations for the Todo App frontend component."""

impl app.fetchTodos -> None {
    todosLoading = True;
    result = root spawn ListTodos();
    todos = result.reports[0] if result.reports else [];
    todosLoading = False;
}

impl app.addTodo -> None {
    if not newTodoText.trim() {
        return;
    }
    response = root spawn AddTodo(title=newTodoText, priority=newPriority);
    newTodo = response.reports[0];
    todos = todos.concat(
        [
            {
                "id": newTodo.id,
                "title": newTodo.title,
                "completed": newTodo.completed,
                "priority": newTodo.priority,
                "parent_id": newTodo.parent_id
            }
        ]
    );
    newTodoText = "";
    newPriority = "medium";
}

impl app.addSubTodo(title: str, parentId: str) -> None {
    response = root spawn AddTodo(title=title, parent_id=parentId);
    newTodo = response.reports[0];
    todos = todos.concat(
        [
            {
                "id": newTodo.id,
                "title": newTodo.title,
                "completed": newTodo.completed,
                "priority": newTodo.priority,
                "parent_id": newTodo.parent_id
            }
        ]
    );
}

impl app.toggleTodo(todoId: str) -> None {
    root spawn ToggleTodo(todo_id=todoId);
    todos = todos.map(
        lambda t: any -> any {
            if t.id == todoId {
                return {
                    "id": t.id,
                    "title": t.title,
                    "completed": not t.completed,
                    "priority": t.priority,
                    "parent_id": t.parent_id
                };
            }
            return t;
        }
    );
}

impl app.deleteTodo(todoId: str) -> None {
    root spawn DeleteTodo(todo_id=todoId);
    todos = todos.filter(
        lambda t: any -> bool { return t.id != todoId and t.parent_id != todoId; }
    );
}

impl app.handleLogin -> None {
    error = "";
    if not username.trim() or not password {
        error = "Please fill in all fields";
        return;
    }
    loading = True;
    success = await jacLogin(username, password);
    loading = False;
    if success {
        isLoggedIn = True;
        username = "";
        password = "";
    } else {
        error = "Invalid username or password";
    }
}

impl app.handleSignup -> None {
    error = "";
    if not username.trim() or not password {
        error = "Please fill in all fields";
        return;
    }
    if password.length < 4 {
        error = "Password must be at least 4 characters";
        return;
    }
    loading = True;
    result = await jacSignup(username, password);
    loading = False;
    if result["success"] {
        isLoggedIn = True;
        username = "";
        password = "";
    } else {
        error = result["error"] if result["error"] else "Signup failed";
    }
}

impl app.handleLogout -> None {
    jacLogout();
    isLoggedIn = False;
    todos = [];
}

impl app.handleSubmit(e: any) -> None {
    e.preventDefault();
    if isSignup {
        await handleSignup();
    } else {
        await handleLogin();
    }
}

impl app.handleTodoKeyPress(e: any) -> None {
    if e.key == "Enter" {
        addTodo();
    }
}

impl app.getRootTodos -> list {
    return todos.filter(
        lambda t: any -> bool { return not t.parent_id or t.parent_id == ""; }
    );
}
