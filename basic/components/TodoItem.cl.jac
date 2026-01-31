"""Todo item component with priority and sub-todos."""

def:pub TodoItem(
    todo: dict, allTodos: list, onToggle: any, onDelete: any, onAddSubTodo: any
) -> any {
    subTodos = allTodos.filter(
        lambda t: any  -> bool { return t.parent_id == todo.id; }
    );
    priority = todo.priority or "medium";
    pColor = "#ef4444"
    if priority == "high"
    else ("#eab308" if priority == "medium" else "#22c55e");

    return
        <div style={{"marginBottom": "0.5rem"}}>
            <div
                style={{
                    "display": "flex",
                    "alignItems": "center",
                    "gap": "0.75rem",
                    "padding": "0.75rem 1rem",
                    "background": "rgba(255,255,255,0.03)",
                    "borderRadius": "10px",
                    "border": "1px solid rgba(200,80,50,0.15)"
                }}
            >
                <input
                    type="checkbox"
                    checked={todo.completed}
                    onChange={lambda -> None { onToggle(todo.id);}}
                    style={{
                        "width": "18px",
                        "height": "18px",
                        "cursor": "pointer",
                        "accentColor": "#d45a30"
                    }}
                />
                <span
                    style={{
                        "flex": "1",
                        "color": (
                            "rgba(255,255,255,0.4)"
                            if todo.completed
                            else "rgba(255,255,255,0.9)"
                        ),
                        "textDecoration": (
                            "line-through" if todo.completed else "none"
                        )
                    }}
                >
                    {todo.title}
                </span>
                <span
                    style={{
                        "padding": "0.15rem 0.5rem",
                        "borderRadius": "10px",
                        "fontSize": "0.65rem",
                        "fontWeight": "600",
                        "textTransform": "uppercase",
                        "background": pColor + "22",
                        "color": pColor,
                        "border": "1px solid " + pColor + "44"
                    }}
                >
                    {priority}
                </span>
                <button
                    onClick={lambda -> None { onDelete(todo.id);}}
                    style={{
                        "background": "none",
                        "border": "none",
                        "color": "rgba(200,80,50,0.5)",
                        "cursor": "pointer",
                        "padding": "0.25rem",
                        "fontSize": "1.2rem"
                    }}
                >
                    ×
                </button>
            </div>
            {(
                <div
                    style={{
                        "marginLeft": "2rem",
                        "marginTop": "0.25rem",
                        "borderLeft": "2px solid rgba(200,80,50,0.3)",
                        "paddingLeft": "1rem"
                    }}
                >
                    {subTodos.map(
                        lambda st: any  -> any { return
                            <TodoItem
                                key={st.id}
                                todo={st}
                                allTodos={allTodos}
                                onToggle={onToggle}
                                onDelete={onDelete}
                                onAddSubTodo={onAddSubTodo}
                            />; }
                    )}
                </div>
            )
            if subTodos.length > 0
            else None}
        </div>;
}
