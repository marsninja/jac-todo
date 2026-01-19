"""Todo App - Client-Side UI."""

import from react { useEffect }
import from "@jac-client/utils" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }

import from .components.TodoItem { TodoItem }
import from .components.AuthForm { AuthForm }
import ".styles.css";

sv import from endpoints { AddTodo, ListTodos, ToggleTodo, DeleteTodo }

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
        todosLoading: bool = True;

    # Check login status on mount
    useEffect(lambda -> None { isLoggedIn = jacIsLoggedIn();checkingAuth = False;}, []);

    # Load todos when logged in
    useEffect(
        lambda -> None { if isLoggedIn {
            fetchTodos();
        }},
        [isLoggedIn]
    );

    # Fetch todos from server
    async def fetchTodos -> None {
        todosLoading = True;
        result = root spawn ListTodos();
        todos = result.reports[0] if result.reports else [];
        todosLoading = False;
    }

    # Add a new todo
    async def addTodo -> None {
        if not newTodoText.trim() {
            return;
        }
        response = root spawn AddTodo(title=newTodoText);
        newTodo = response.reports[0];
        todos = todos.concat(
            [
                {
                    "id": newTodo.id,
                    "title": newTodo.title,
                    "completed": newTodo.completed
                }
            ]
        );
        newTodoText = "";
    }

    # Toggle todo completion
    async def toggleTodo(todoId: str) -> None {
        root spawn ToggleTodo(todo_id=todoId);
        todos = todos.map(
            lambda t: any  -> any { if t.id == todoId {
                return {"id": t.id, "title": t.title, "completed": not t.completed};
            }return t; }
        );
    }

    # Delete a todo
    async def deleteTodo(todoId: str) -> None {
        root spawn DeleteTodo(todo_id=todoId);
        todos = todos.filter(lambda t: any  -> bool { return t.id != todoId; });
    }

    # Handle login
    async def handleLogin -> None {
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

    # Handle signup
    async def handleSignup -> None {
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

    # Handle logout
    def handleLogout -> None {
        jacLogout();
        isLoggedIn = False;
        todos = [];
        username = "";
        password = "";
        error = "";
    }

    # Handle form submit
    async def handleSubmit(e: any) -> None {
        e.preventDefault();
        if isSignup {
            await handleSignup();
        } else {
            await handleLogin();
        }
    }

    # Handle enter key for todo input
    def handleTodoKeyPress(e: any) -> None {
        if e.key == "Enter" {
            addTodo();
        }
    }

    # Loading screen
    if checkingAuth {
        return <div className="loading-screen">Loading...</div>;
    }

    # Logged in - Show Todo List
    if isLoggedIn {
        return
            <div className="app-container">
                <div className="header">
                    <h1 className="header-title">My Todos</h1>
                    <button className="btn-logout" onClick={handleLogout}>
                        Log Out
                    </button>
                </div>
                <div className="todo-input-section">
                    <input
                        type="text"
                        className="todo-input"
                        value={newTodoText}
                        onChange={lambda e: any  -> None { newTodoText = e.target.value;}}
                        onKeyPress={handleTodoKeyPress}
                        placeholder="What needs to be done?"
                    />
                    <button className="btn-add" onClick={lambda -> None { addTodo();}}>
                        Add
                    </button>
                </div>
                {(<div className="loading-todos">Loading todos...</div>)
                if todosLoading
                else None}
                {(
                    <div>
                        {(<p className="empty-todos">No todos yet. Add one above!</p>)
                        if todos.length == 0
                        else None}{todos.map(
                            lambda todo: any  -> any { return
                                <TodoItem
                                    key={todo.id}
                                    todo={todo}
                                    onToggle={toggleTodo}
                                    onDelete={deleteTodo}
                                />; }
                        )}
                    </div>
                )
                if not todosLoading
                else None}
                <div className="footer">
                    {todos.filter(lambda t: any  -> bool { return not t.completed; }).length} items left
                </div>
            </div>;
    }

    # Not logged in - Show Auth Form
    return
        <AuthForm
            isSignup={isSignup}
            username={username}
            password={password}
            error={error}
            loading={loading}
            onUsernameChange={lambda e: any  -> None { username = e.target.value;}}
            onPasswordChange={lambda e: any  -> None { password = e.target.value;}}
            onSubmit={handleSubmit}
            onToggleMode={lambda -> None { isSignup = not isSignup;error = "";}}
        />;
}
