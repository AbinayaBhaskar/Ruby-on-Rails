require 'rails_helper'

describe Employees::SessionsController, type: :request do
  context 'when logging in with valid email and password' do
    let(:employee) { create(:employee, email: "chandrika@gmail.com", password: "password") }
    let(:response_payload) do
      {
        message: "Logged in",
        data: {
          id: employee.id,
          name: employee.name,
          email: employee.email,
          manager_id: employee.manager_id,
          created_at: employee.created_at,
          updated_at: employee.updated_at,
          jti: employee.jti
        }
      }.to_json
    end

    before do
      params = {
        employee: {
          name: employee.name,
          email: employee.email,
          password: employee.password
        }
      }
      post "/employees/login", params:, as: :json
    end

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end

    it 'returns signed in employee' do
      expect(response.body).to match(response_payload)
    end
  end

  context 'when passing invalid email id or password' do
    before do
      employee = create(:employee)
      params = {
        employee: {
          email: "1@gmail.com",
          password: employee.password
        }
      }
      post "/employees/login", params:, as: :json
    end

    it 'returns 401' do
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an error message' do
      expect(JSON.parse(response.body)["error"]).to eq("Invalid Email or password.")
    end
  end

  context 'when passing null value' do
    let(:employee) { create(:employee) }

    before do
      params = {
        employee: {
          name: employee.name,
          email: nil,
          password: "password"
        }
      }
      post "/employees/login", params:, as: :json
    end

    it 'returns 401' do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
