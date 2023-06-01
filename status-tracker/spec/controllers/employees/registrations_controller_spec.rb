require 'rails_helper'

describe Employees::RegistrationsController, type: :request do
  context "when creating a new employee" do
    before do
      employees_params = {
        employee: {
          name: "chandrika",
          email: "chandrika1@gmail.com",
          password: "password"
        }
      }
      post "/employees", params: employees_params, as: :json
    end

    let(:employee) { Employee.find_by(email: 'chandrika1@gmail.com') }
    let(:response_payload) do
      {
        message: "Signed up",
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

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns registered employee' do
      expect(response.body).to match(response_payload)
    end

    it 'returns a token' do
      expect(response.headers['Authorization']).to be_present
    end
  end

  context 'when an email already exists' do
    before do
      params = {
        employee: {
          email: "chandrika@gmail.com",
          password: "password"
        }
      }
      create(:employee, email: "chandrika@gmail.com")
      post "/employees", params:, as: :json
    end

    it 'returns 422' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns an error message' do
      expect(JSON.parse(response.body)["message"]).to eq("inactive")
    end
  end

  context 'when passing empty password' do
    before do
      params = {
        employee: {
          email: "chandu@gmail.com",
          password: nil
        }
      }
      post "/employees", params:, as: :json
    end

    it 'returns 422' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns an error message' do
      expect(JSON.parse(response.body)["message"]).to eq("inactive")
    end
  end

  context 'when passing an empty email' do
    before do
      params = {
        employee: {
          email: nil,
          password: "password"
        }
      }
      post "/employees", params:, as: :json
    end

    it 'returns 422' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns an error message' do
      expect(JSON.parse(response.body)["message"]).to eq("inactive")
    end
  end
end
