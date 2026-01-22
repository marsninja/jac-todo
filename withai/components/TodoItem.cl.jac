"""Todo item component with priority, sub-todos, and ingredient details."""

def:pub TodoItem(todo: dict, allTodos: list, onToggle: any, onDelete: any, onAddSubTodo: any) -> any {
    subTodos = allTodos.filter(lambda t: any -> bool { return t.parent_id == todo.id; });
    priority = todo.priority if todo.priority else "medium";
    pColor = "#ef4444" if priority == "high" else ("#eab308" if priority == "medium" else "#22c55e");
    hasIngredientData = todo.cost != None and todo.cost != undefined;
    isCarby = todo.carby if todo.carby else False;

    return
        <div style={{"marginBottom": "0.5rem"}}>
            <div style={{
                "display": "flex",
                "alignItems": "center",
                "gap": "0.75rem",
                "padding": "0.75rem 1rem",
                "background": ("rgba(99,102,241,0.05)" if hasIngredientData else "rgba(255,255,255,0.03)"),
                "borderRadius": "10px",
                "border": ("1px solid rgba(99,102,241,0.2)" if hasIngredientData else "1px solid rgba(200,80,50,0.15)")
            }}>
                <input type="checkbox" checked={todo.completed} onChange={lambda -> None { onToggle(todo.id); }}
                    style={{"width": "18px", "height": "18px", "cursor": "pointer", "accentColor": ("#6366f1" if hasIngredientData else "#d45a30")}} />

                <span style={{
                    "flex": "1",
                    "color": ("rgba(255,255,255,0.4)" if todo.completed else "rgba(255,255,255,0.9)"),
                    "textDecoration": ("line-through" if todo.completed else "none")
                }}>
                    {todo.title}
                </span>

                {(
                    <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem"}}>
                        <span style={{
                            "padding": "0.15rem 0.5rem",
                            "borderRadius": "6px",
                            "fontSize": "0.65rem",
                            "fontWeight": "600",
                            "background": ("rgba(251,191,36,0.2)" if isCarby else "rgba(34,197,94,0.2)"),
                            "color": ("#fbbf24" if isCarby else "#22c55e"),
                            "border": ("1px solid rgba(251,191,36,0.4)" if isCarby else "1px solid rgba(34,197,94,0.4)")
                        }}>
                            {("CARBS" if isCarby else "LOW-CARB")}
                        </span>
                        <span style={{
                            "padding": "0.15rem 0.5rem",
                            "borderRadius": "6px",
                            "fontSize": "0.7rem",
                            "fontWeight": "700",
                            "color": "#22c55e",
                            "background": "rgba(34,197,94,0.15)",
                            "border": "1px solid rgba(34,197,94,0.3)"
                        }}>
                            ${todo.cost.toFixed(2)}
                        </span>
                    </div>
                ) if hasIngredientData else (
                    <span style={{
                        "padding": "0.15rem 0.5rem",
                        "borderRadius": "10px",
                        "fontSize": "0.65rem",
                        "fontWeight": "600",
                        "textTransform": "uppercase",
                        "background": f"{pColor}22",
                        "color": pColor,
                        "border": f"1px solid {pColor}44"
                    }}>
                        {priority}
                    </span>
                )}

                <button onClick={lambda -> None { onDelete(todo.id); }}
                    style={{"background": "none", "border": "none", "color": "rgba(200,80,50,0.5)", "cursor": "pointer", "padding": "0.25rem", "fontSize": "1.2rem"}}>x</button>
            </div>

            {(
                <div style={{"marginLeft": "2rem", "marginTop": "0.25rem", "borderLeft": "2px solid rgba(200,80,50,0.3)", "paddingLeft": "1rem"}}>
                    {subTodos.map(lambda st: any -> any {
                        return <TodoItem key={st.id} todo={st} allTodos={allTodos} onToggle={onToggle} onDelete={onDelete} onAddSubTodo={onAddSubTodo} />;
                    })}
                </div>
            ) if subTodos.length > 0 else None}
        </div>;
}
