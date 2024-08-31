% Typical office building model
% Inputs:
% T_ref - reference temperature
% T_i - initial temperature
% T_h - initial heater temperature
% yi,max - maximum supply air temperature
% mdot_si - supply air mass flow rate
% cp - specific heat capacity of air
% m - number of rooms
% T_sa - sol-air temperature
% Outputs:
% T_i - indoor temperature
% T_h - heater temperature

function [T_i, T_h] = office_building_model(T_ref, T_i, T_h, yi,max, mdot_si, cp, m, T_sa)

% Calculate the heat flux through the external walls
Q_walls = h_walls * (T_i - T_sa);

% Calculate the heat flux from the heater
Q_heater = mdot_si * cp * (T_h - T_i);

% Calculate the heat flux from the occupants and lights
Q_occupants = random('Uniform', 100, 300);
Q_lights = random('Uniform', 100, 200);

% Calculate the total heat flux
Q_total = Q_walls + Q_heater + Q_occupants + Q_lights;

% Calculate the rate of change of the indoor temperature
dT_i = Q_total / (m * yi,max * cp);

% Calculate the rate of change of the heater temperature
dT_h = -Q_heater / (m_h * cp_h);

% Update the indoor temperature and heater temperature
T_i = T_i + dT_i;
T_h = T_h + dT_h;

end

% Model predictive control (MPC) algorithm
function [u_opt] = mpc_algorithm(x_ref, x_current, model, N, Q, R)

% Calculate the predicted state at each time step
x_pred = zeros(N+1, 1);
x_pred(1) = x_current;
for i = 1:N
    x_pred(i+1) = model(x_pred(i), u(i));
end

% Calculate the cost function
J = 0;
for i = 1:N
    J = J + (x_pred(i) - x_ref(i))^2 * Q + (u(i))^2 * R;
end

% Solve the quadratic programming problem to find the optimal control inputs
u_opt = quadprog(2*R, [], [], [], Q, x_ref - x_pred, [], [], []);

end

% Simulation parameters
T_ref = 22;
T_i = 10;
T_h = 27;
yi,max = 25;
mdot_si = 0.4530;
cp = 1005;
m = 14;
T_sa = 20;
N = 10;
Q = 10;
R = 1;

% Simulation loop
T_i_history = zeros(1000, 1);
T_h_history = zeros(1000, 1);
for t = 1:1000

    % Calculate the control inputs
    u = mpc_algorithm(T_ref, T_i(t), @office_building_model, N, Q, R);

    % Simulate the system
    [T_i(t+1), T_h(t+1)] = office_building_model(T_ref, T_i(t), T_h(t), yi,max, mdot_si, cp, m, T_sa);

    % Store the results
    T_i_history(t) = T_i(t);
    T_h_history(t) = T_h(t);

end

% Plot the results
figure;
plot(T_i_history, 'b');
hold on;
plot(T_ref, 'r');
legend('Indoor temperature', 'Reference temperature');
xlabel('Time (s)');
ylabel('Temperature (°C)');