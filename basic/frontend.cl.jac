"""Todo App - Client-Side UI with priorities and sub-todos."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import ".styles.css";

import from .components.TodoItem { TodoItem }
import from .components.AuthForm { AuthForm }

sv import from main { AddTodo, ListTodos, ToggleTodo, DeleteTodo }

def:pub app -> any {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        todos: list = [],
        newTodoText: str = "",
        newPriority: str = "medium",
        todosLoading: bool = True;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn { fetchTodos(); }
    }

    async def fetchTodos -> None {
        todosLoading = True;
        result = root spawn ListTodos();
        todos = result.reports[0] if result.reports else [];
        todosLoading = False;
    }

    async def addTodo -> None {
        if not newTodoText.trim() { return; }
        response = root spawn AddTodo(title=newTodoText, priority=newPriority);
        newTodo = response.reports[0];
        todos = todos.concat([{"id": newTodo.id, "title": newTodo.title, "completed": newTodo.completed, "priority": newTodo.priority, "parent_id": newTodo.parent_id}]);
        newTodoText = "";
        newPriority = "medium";
    }

    async def addSubTodo(title: str, parentId: str) -> None {
        response = root spawn AddTodo(title=title, parent_id=parentId);
        newTodo = response.reports[0];
        todos = todos.concat([{"id": newTodo.id, "title": newTodo.title, "completed": newTodo.completed, "priority": newTodo.priority, "parent_id": newTodo.parent_id}]);
    }

    async def toggleTodo(todoId: str) -> None {
        root spawn ToggleTodo(todo_id=todoId);
        todos = todos.map(lambda t: any -> any {
            if t.id == todoId { return {"id": t.id, "title": t.title, "completed": not t.completed, "priority": t.priority, "parent_id": t.parent_id}; }
            return t;
        });
    }

    async def deleteTodo(todoId: str) -> None {
        root spawn DeleteTodo(todo_id=todoId);
        todos = todos.filter(lambda t: any -> bool { return t.id != todoId and t.parent_id != todoId; });
    }

    async def handleLogin -> None {
        error = "";
        if not username.trim() or not password { error = "Please fill in all fields"; return; }
        loading = True;
        success = await jacLogin(username, password);
        loading = False;
        if success { isLoggedIn = True; username = ""; password = ""; }
        else { error = "Invalid username or password"; }
    }

    async def handleSignup -> None {
        error = "";
        if not username.trim() or not password { error = "Please fill in all fields"; return; }
        if password.length < 4 { error = "Password must be at least 4 characters"; return; }
        loading = True;
        result = await jacSignup(username, password);
        loading = False;
        if result["success"] { isLoggedIn = True; username = ""; password = ""; }
        else { error = result["error"] if result["error"] else "Signup failed"; }
    }

    def handleLogout -> None {
        jacLogout();
        isLoggedIn = False;
        todos = [];
    }

    async def handleSubmit(e: any) -> None {
        e.preventDefault();
        if isSignup { await handleSignup(); } else { await handleLogin(); }
    }

    def handleTodoKeyPress(e: any) -> None {
        if e.key == "Enter" { addTodo(); }
    }

    def getRootTodos -> list {
        return todos.filter(lambda t: any -> bool { return not t.parent_id or t.parent_id == ""; });
    }

    if checkingAuth {
        return <div style={{"minHeight": "100vh", "margin": "0", "position": "absolute", "top": "0", "left": "0", "right": "0", "bottom": "0", "background": "linear-gradient(135deg, #0a0a0a 0%, #151010 50%, #0a0a0a 100%)", "display": "flex", "justifyContent": "center", "alignItems": "center", "color": "rgba(255,255,255,0.6)", "fontFamily": "system-ui"}}>Loading...</div>;
    }

    if isLoggedIn {
        rootTodos = getRootTodos();

        return
            <div style={{"minHeight": "100vh", "margin": "0", "position": "absolute", "top": "0", "left": "0", "right": "0", "bottom": "0", "background": "linear-gradient(135deg, #0a0a0a 0%, #151010 50%, #0a0a0a 100%)", "padding": "2rem", "fontFamily": "system-ui, -apple-system, sans-serif", "overflow": "auto"}}>
                <div style={{"maxWidth": "700px", "margin": "0 auto"}}>
                    <div style={{"background": "rgba(25,20,20,0.95)", "borderRadius": "16px", "border": "1px solid rgba(200,80,50,0.2)", "padding": "1.5rem", "marginBottom": "1.5rem"}}>
                        <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center"}}>
                            <div>
                                <h1 style={{"margin": "0", "color": "white", "fontSize": "1.75rem"}}>TaskFlow</h1>
                                <p style={{"margin": "0.25rem 0 0 0", "color": "rgba(255,255,255,0.5)", "fontSize": "0.85rem"}}>Organize tasks with priorities & sub-tasks</p>
                            </div>
                            <button onClick={handleLogout} style={{"padding": "0.5rem 1rem", "background": "rgba(200,80,50,0.15)", "color": "#d45a30", "border": "1px solid rgba(200,80,50,0.3)", "borderRadius": "8px", "cursor": "pointer"}}>Sign Out</button>
                        </div>
                    </div>

                    <div style={{"background": "rgba(25,20,20,0.95)", "borderRadius": "16px", "border": "1px solid rgba(200,80,50,0.2)", "padding": "1.5rem", "marginBottom": "1.5rem"}}>
                        <div style={{"display": "flex", "gap": "0.75rem", "marginBottom": "1rem"}}>
                            <input type="text" value={newTodoText} onChange={lambda e: any -> None { newTodoText = e.target.value; }} onKeyPress={handleTodoKeyPress} placeholder="What needs to be done?" style={{"flex": "1", "padding": "0.75rem 1rem", "background": "rgba(255,255,255,0.05)", "border": "1px solid rgba(200,80,50,0.2)", "borderRadius": "8px", "color": "white", "fontSize": "1rem", "outline": "none"}} />
                            <button onClick={lambda -> None { addTodo(); }} style={{"padding": "0.75rem 1.5rem", "background": "linear-gradient(135deg, #d45a30, #a33d1a)", "color": "white", "border": "none", "borderRadius": "8px", "cursor": "pointer", "fontWeight": "600"}}>Add</button>
                        </div>
                        <div style={{"display": "flex", "gap": "0.5rem", "alignItems": "center"}}>
                            <span style={{"color": "rgba(255,255,255,0.5)", "fontSize": "0.85rem"}}>Priority:</span>
                            <button onClick={lambda -> None { newPriority = "high"; }} style={{"padding": "0.3rem 0.75rem", "borderRadius": "6px", "cursor": "pointer", "fontSize": "0.8rem", "background": ("rgba(239,68,68,0.25)" if newPriority == "high" else "rgba(255,255,255,0.05)"), "border": ("1px solid #ef4444" if newPriority == "high" else "1px solid rgba(255,255,255,0.1)"), "color": ("#ef4444" if newPriority == "high" else "rgba(255,255,255,0.5)")}}>High</button>
                            <button onClick={lambda -> None { newPriority = "medium"; }} style={{"padding": "0.3rem 0.75rem", "borderRadius": "6px", "cursor": "pointer", "fontSize": "0.8rem", "background": ("rgba(234,179,8,0.25)" if newPriority == "medium" else "rgba(255,255,255,0.05)"), "border": ("1px solid #eab308" if newPriority == "medium" else "1px solid rgba(255,255,255,0.1)"), "color": ("#eab308" if newPriority == "medium" else "rgba(255,255,255,0.5)")}}>Medium</button>
                            <button onClick={lambda -> None { newPriority = "low"; }} style={{"padding": "0.3rem 0.75rem", "borderRadius": "6px", "cursor": "pointer", "fontSize": "0.8rem", "background": ("rgba(34,197,94,0.25)" if newPriority == "low" else "rgba(255,255,255,0.05)"), "border": ("1px solid #22c55e" if newPriority == "low" else "1px solid rgba(255,255,255,0.1)"), "color": ("#22c55e" if newPriority == "low" else "rgba(255,255,255,0.5)")}}>Low</button>
                        </div>
                    </div>

                    <div style={{"background": "rgba(25,20,20,0.95)", "borderRadius": "16px", "border": "1px solid rgba(200,80,50,0.2)", "padding": "1.5rem"}}>
                        {(
                            <div style={{"textAlign": "center", "padding": "2rem", "color": "rgba(255,255,255,0.6)"}}>Loading tasks...</div>
                        ) if todosLoading else (
                            <div>
                                {(
                                    <div style={{"textAlign": "center", "padding": "3rem", "color": "rgba(255,255,255,0.6)"}}>No tasks yet. Add one above!</div>
                                ) if rootTodos.length == 0 else (
                                    <div>
                                        {[<TodoItem key={todo.id} todo={todo} allTodos={todos} onToggle={toggleTodo} onDelete={deleteTodo} onAddSubTodo={addSubTodo} /> for todo in rootTodos]}
                                    </div>
                                )}
                            </div>
                        )}
                    </div>

                    <div style={{"marginTop": "1.5rem", "textAlign": "center", "color": "rgba(212,90,48,0.7)", "fontSize": "0.85rem"}}>
                        {todos.filter(lambda t: any -> bool { return not t.completed; }).length} items remaining
                    </div>
                </div>
            </div>;
    }

    return
        <AuthForm isSignup={isSignup} username={username} password={password} error={error} loading={loading}
            onUsernameChange={lambda e: any -> None { username = e.target.value; }}
            onPasswordChange={lambda e: any -> None { password = e.target.value; }}
            onSubmit={handleSubmit}
            onToggleMode={lambda -> None { isSignup = not isSignup; error = ""; }}
        />;
}
