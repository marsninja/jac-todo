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
        if isLoggedIn {
            fetchTodos();
        }
    }

    async def fetchTodos -> None {
        todosLoading = True;
        result = root spawn ListTodos();
        todos = result.reports[0] if result.reports else [];
        todosLoading = False;
    }

    async def addTodo -> None {
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

    async def addSubTodo(title: str, parentId: str) -> None {
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

    async def toggleTodo(todoId: str) -> None {
        root spawn ToggleTodo(todo_id=todoId);
        todos = todos.map(
            lambda t: any  -> any { if t.id == todoId {
                return {
                    "id": t.id,
                    "title": t.title,
                    "completed": not t.completed,
                    "priority": t.priority,
                    "parent_id": t.parent_id
                };
            }return t; }
        );
    }

    async def deleteTodo(todoId: str) -> None {
        root spawn DeleteTodo(todo_id=todoId);
        todos = todos.filter(
            lambda t: any  -> bool { return t.id != todoId and t.parent_id != todoId; }
        );
    }

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

    def handleLogout -> None {
        jacLogout();
        isLoggedIn = False;
        todos = [];
    }

    async def handleSubmit(e: any) -> None {
        e.preventDefault();
        if isSignup {
            await handleSignup();
        } else {
            await handleLogin();
        }
    }

    def handleTodoKeyPress(e: any) -> None {
        if e.key == "Enter" {
            addTodo();
        }
    }

    def getRootTodos -> list {
        return todos.filter(
            lambda t: any  -> bool { return not t.parent_id or t.parent_id == ""; }
        );
    }

    if checkingAuth {
        return
            <div className="app-loading">
                Loading...
            </div>;
    }

    if isLoggedIn {
        rootTodos = getRootTodos();
        return
            <div className="app-container">
                <div className="app-content">
                    <div className="card">
                        <div className="card-header">
                            <div>
                                <h1 className="app-title">
                                    TaskFlow
                                </h1>
                                <p className="app-subtitle">
                                    Organize tasks with priorities & sub-tasks
                                </p>
                            </div>
                            <button onClick={handleLogout} className="btn-signout">
                                Sign Out
                            </button>
                        </div>
                    </div>
                    <div className="card">
                        <div className="add-row">
                            <input
                                type="text"
                                value={newTodoText}
                                onChange={lambda e: any  -> None { newTodoText = e.target.value;}}
                                onKeyPress={handleTodoKeyPress}
                                placeholder="What needs to be done?"
                                className="todo-input"
                            />
                            <button
                                onClick={lambda -> None { addTodo();}}
                                className="btn-add"
                            >
                                Add
                            </button>
                        </div>
                        <div className="priority-row">
                            <span className="priority-label">
                                Priority:
                            </span>
                            <button
                                onClick={lambda -> None { newPriority = "high";}}
                                className={(
                                    "priority-btn priority-btn-high"
                                    if newPriority == "high"
                                    else "priority-btn"
                                )}
                            >
                                High
                            </button>
                            <button
                                onClick={lambda -> None { newPriority = "medium";}}
                                className={(
                                    "priority-btn priority-btn-medium"
                                    if newPriority == "medium"
                                    else "priority-btn"
                                )}
                            >
                                Medium
                            </button>
                            <button
                                onClick={lambda -> None { newPriority = "low";}}
                                className={(
                                    "priority-btn priority-btn-low"
                                    if newPriority == "low"
                                    else "priority-btn"
                                )}
                            >
                                Low
                            </button>
                        </div>
                    </div>
                    <div className="card">
                        {(
                            <div className="loading-message">
                                Loading tasks...
                            </div>
                        )
                        if todosLoading
                        else (
                            <div>
                                {(
                                    <div className="empty-message">
                                        No tasks yet. Add one above!
                                    </div>
                                )
                                if rootTodos.length == 0
                                else (
                                    <div>
                                        {[
                                            <TodoItem
                                                key={todo.id}
                                                todo={todo}
                                                allTodos={todos}
                                                onToggle={toggleTodo}
                                                onDelete={deleteTodo}
                                                onAddSubTodo={addSubTodo}
                                            /> for todo in rootTodos
                                        ]}
                                    </div>
                                )}
                            </div>
                        )}
                    </div>
                    <div className="remaining-count">
                        {todos.filter(
                            lambda t: any  -> bool { return not t.completed; }
                        ).length}items remaining
                    </div>
                </div>
            </div>;
    }

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
