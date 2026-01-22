"""Authentication form component."""

def:pub AuthForm(
    isSignup: bool,
    username: str,
    password: str,
    error: str,
    loading: bool,
    onUsernameChange: any,
    onPasswordChange: any,
    onSubmit: any,
    onToggleMode: any
) -> any {
    containerStyle = {
        "minHeight": "100vh",
        "margin": "0",
        "padding": "1rem",
        "display": "flex",
        "alignItems": "center",
        "justifyContent": "center",
        "background": "linear-gradient(135deg, #0a0a0a 0%, #151010 50%, #0a0a0a 100%)",
        "fontFamily": "system-ui, -apple-system, sans-serif",
        "position": "absolute",
        "top": "0",
        "left": "0",
        "right": "0",
        "bottom": "0"
    };
    cardStyle = {
        "background": "rgba(25,20,20,0.95)",
        "borderRadius": "20px",
        "border": "1px solid rgba(200,80,50,0.2)",
        "padding": "2.5rem",
        "width": "100%",
        "maxWidth": "400px"
    };
    inputStyle = {
        "width": "100%",
        "padding": "0.875rem 1rem",
        "background": "rgba(255,255,255,0.05)",
        "border": "1px solid rgba(200,80,50,0.2)",
        "borderRadius": "10px",
        "color": "white",
        "fontSize": "1rem",
        "outline": "none",
        "boxSizing": "border-box"
    };
    btnStyle = {
        "width": "100%",
        "padding": "0.875rem",
        "background": "linear-gradient(135deg, #d45a30, #a33d1a)",
        "color": "white",
        "border": "none",
        "borderRadius": "10px",
        "fontSize": "1rem",
        "fontWeight": "600",
        "cursor": "pointer"
    };

    return
        <div style={containerStyle}>
            <div style={cardStyle}>
                <div style={{"textAlign": "center", "marginBottom": "2rem"}}>
                    <div
                        style={{
                            "width": "60px",
                            "height": "60px",
                            "margin": "0 auto 1rem",
                            "background": "linear-gradient(135deg, #d45a30, #a33d1a)",
                            "borderRadius": "16px",
                            "display": "flex",
                            "alignItems": "center",
                            "justifyContent": "center",
                            "fontSize": "1.5rem"
                        }}
                    >
                        📋
                    </div>
                    <h1
                        style={{
                            "margin": "0",
                            "color": "white",
                            "fontSize": "1.75rem",
                            "fontWeight": "bold"
                        }}
                    >
                        MealFlow
                    </h1>
                    <p
                        style={{
                            "margin": "0.5rem 0 0",
                            "color": "rgba(255,255,255,0.6)",
                            "fontSize": "0.9rem"
                        }}
                    >
                        {("Create your account" if isSignup else "Welcome back")}
                    </p>
                </div>
                {(
                    <div
                        style={{
                            "marginBottom": "1.5rem",
                            "padding": "0.875rem",
                            "background": "rgba(239,68,68,0.15)",
                            "border": "1px solid rgba(239,68,68,0.3)",
                            "borderRadius": "10px",
                            "color": "#f87171",
                            "fontSize": "0.9rem"
                        }}
                    >
                        {error}
                    </div>
                )
                if error
                else None}
                <form onSubmit={onSubmit}>
                    <div style={{"marginBottom": "1rem"}}>
                        <label
                            style={{
                                "display": "block",
                                "color": "rgba(255,255,255,0.6)",
                                "fontSize": "0.85rem",
                                "marginBottom": "0.5rem"
                            }}
                        >
                            Username
                        </label>
                        <input
                            type="text"
                            value={username}
                            onChange={onUsernameChange}
                            placeholder="Enter username"
                            style={inputStyle}
                        />
                    </div>
                    <div style={{"marginBottom": "1.5rem"}}>
                        <label
                            style={{
                                "display": "block",
                                "color": "rgba(255,255,255,0.6)",
                                "fontSize": "0.85rem",
                                "marginBottom": "0.5rem"
                            }}
                        >
                            Password
                        </label>
                        <input
                            type="password"
                            value={password}
                            onChange={onPasswordChange}
                            placeholder="Enter password"
                            style={inputStyle}
                        />
                    </div>
                    <button
                        type="submit"
                        disabled={loading}
                        style={{** btnStyle, "opacity": ("0.7" if loading else "1")}}
                    >
                        {(
                            "Processing..."
                            if loading
                            else ("Create Account" if isSignup else "Sign In")
                        )}
                    </button>
                </form>
                <div style={{"marginTop": "1.5rem", "textAlign": "center"}}>
                    <span
                        style={{"color": "rgba(255,255,255,0.5)", "fontSize": "0.9rem"}}
                    >
                        {(
                            "Already have an account? "
                            if isSignup
                            else "Don't have an account? "
                        )}
                    </span>
                    <button
                        type="button"
                        onClick={onToggleMode}
                        style={{
                            "background": "none",
                            "border": "none",
                            "color": "#d45a30",
                            "fontWeight": "600",
                            "cursor": "pointer",
                            "fontSize": "0.9rem"
                        }}
                    >
                        {("Sign In" if isSignup else "Sign Up")}
                    </button>
                </div>
            </div>
        </div>;
}
