import os
import joblib
import pandas as pd
import csv
from flask import Flask, request, render_template, jsonify

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

MODEL_DIR = os.path.join(BASE_DIR, "models")
OUTPUT_FILE = os.path.join(BASE_DIR, "output/predictions.csv")  # CSV directly project folder me

# Loading models
models = {
    "HistGradientBoosting": joblib.load(os.path.join(MODEL_DIR, "HistGradientBoosting_higgs_model.pkl")),
    "RandomForest": joblib.load(os.path.join(MODEL_DIR, "RandomForest_higgs_model.pkl")),
    "XGBoost": joblib.load(os.path.join(MODEL_DIR, "XGBoost_higgs_model.pkl")),
    "LogisticRegression": joblib.load(os.path.join(MODEL_DIR, "LogisticRegression_higgs_model.pkl"))
}

# Loading feature lists
feature_files = {
    "HistGradientBoosting": os.path.join(MODEL_DIR, "HistGradientBoosting_features.pkl"),
    "RandomForest": os.path.join(MODEL_DIR, "RandomForest_features.pkl"),
    "XGBoost": os.path.join(MODEL_DIR, "XGBoost_features.pkl"),
    "LogisticRegression": os.path.join(MODEL_DIR, "LogisticRegression_features.pkl")
}

# Loading scaler if used
scalers = {
    "HistGradientBoosting": joblib.load(os.path.join(MODEL_DIR, "scaler_higgs.pkl")),
}

# Helper function for prediction
def predict_model(model_name, input_data):
    model = models[model_name]
    features = joblib.load(feature_files[model_name])

    X_input = pd.DataFrame([input_data])

    # Filling missing features with 0 to reach 41
    for col in features:
        if col not in X_input.columns:
            X_input[col] = 0

    # Ensuring correct column order
    X_input = X_input[features]

    # Appling scaler if exists
    if model_name in scalers:
        X_input = scalers[model_name].transform(X_input)

    # Predicting 0/1 and mapping to S/B
    raw_pred = model.predict(X_input)[0]
    return "S" if raw_pred == 1 else "B"

# Home route
@app.route('/')
def home():
    features = joblib.load(feature_files["HistGradientBoosting"])[:30]
    return render_template('index.html', features=features)

# Predicting route
@app.route('/predict', methods=['POST'])
def predict():
    try:
        model_name = request.form.get("model")
        if model_name not in models:
            return jsonify({"error": "Invalid model selected"})

        input_data = {k: float(v) for k, v in request.form.items() if k != "model"}

        prediction = predict_model(model_name, input_data)

        # Saving input + model + prediction to CSV
        fieldnames = list(input_data.keys()) + ["model", "prediction"]
        file_exists = os.path.isfile(OUTPUT_FILE)

        with open(OUTPUT_FILE, mode="a", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            if not file_exists:
                writer.writeheader()
            row = input_data.copy()
            row["model"] = model_name
            row["prediction"] = prediction
            writer.writerow(row)

        features = joblib.load(feature_files["HistGradientBoosting"])[:30]
        return render_template('index.html', features=features,
                               prediction_text=f"Prediction ({model_name}): {prediction}")

    except Exception as e:
        return jsonify({"error": str(e)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)